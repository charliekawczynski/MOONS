      module PCG_solver_mod
      use mesh_mod
      use apply_BCs_mod
      use apply_Stitches_mod
      use norms_mod
      use ops_discrete_mod
      use ops_aux_mod
      use BCs_mod
      use CG_aux_mod
      use export_raw_processed_mod
      use SF_mod
      use VF_mod
      use ops_norms_mod
      use IO_tools_mod
      use omp_lib

      use matrix_free_params_mod
      implicit none

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

      private
      public :: solve_PCG
      interface solve_PCG;      module procedure solve_PCG_SF;   end interface
      interface solve_PCG;      module procedure solve_PCG_VF;   end interface

      real(cp),parameter :: tol_abs = 10.0_cp**(-28.0_cp)
      character(len=19) :: norm_fmt = '(I10,7E40.28E3,I10)'

      contains

      subroutine solve_PCG_SF(operator,operator_explicit,name,x,b,vol,k,m,&
        MFP,n,tol,norm,compute_norms,un,tempx,tempk,Ax,r,p,N_iter,z,Minv)
        implicit none
        external :: operator,operator_explicit
        character(len=1),intent(in) :: name
        type(SF),intent(inout) :: x
        type(SF),intent(in) :: b,vol,Minv
        type(VF),intent(in) :: k
        type(VF),intent(inout) :: tempk
        type(mesh),intent(in) :: m
        type(norms),intent(inout) :: norm
        integer,intent(in) :: n,un
        real(cp),intent(in) :: tol
        integer,intent(inout) :: N_iter
        logical,intent(in) :: compute_norms
        type(matrix_free_params),intent(in) :: MFP
        type(SF),intent(inout) :: tempx,Ax,r,p,z
        type(norms) :: norm_res0
        integer :: i,i_earlyExit
        real(cp) :: alpha,rhok,rhokp1,res_norm ! betak = rhokp1/rhok
        real(cp) :: temp_Ln
        integer :: i_debug
        logical :: i_stop
        i_stop = .false.
        ! if (i_stop) i_debug = newAndOpen('out/LDC/','PPE_out')
        if (i_stop) i_debug = 6

        if (i_stop) write(*,*) ' ************************* START PPE ************************* '
        ! ----------------------- MODIFY RHS -----------------------
        call multiply(r,b,vol)
        ! if (i_stop) then; call Ln(temp_Ln,b,2.0_cp); write(i_debug,*) 'L2(b) = ',temp_Ln; endif
        ! call apply_stitches(r,m)
        ! if (i_stop) then; call Ln(temp_Ln,r,2.0_cp); write(i_debug,*) 'L2(vol*b) = ',temp_Ln; endif
        ! THE FOLLOWING MODIFICATION SHOULD BE READ VERY CAREFULLY.
        ! RHS MODIFCATIONS ARE EXPLAINED IN DOCUMENTATION.
        if (.not.x%is_CC) then
          call assign(p,r)
          call modify_forcing1(r,p,m,x)
        endif
        call assign(p,0.0_cp)
        call apply_BCs(p,m) ! p has BCs for x
        call zeroGhostPoints_conditional(p,m)
        call operator_explicit(Ax,p,k,m,MFP,tempk)
        if (i_stop) then; write(i_debug,*) 'mean(Ap_explicit) = ',physical_mean(Ax); endif
        call multiply(Ax,vol)
        call zeroWall_conditional(Ax,m,x) ! Does nothing in PPE
        call subtract(r,Ax)
        if (i_stop) then; write(i_debug,*) 'mean(r_pre_subtract_mean) = ',physical_mean(r); endif
        if (x%all_Neumann) call subtract_physical_mean(r)
        ! ----------------------------------------------------------
        if (i_stop) then; call Ln(temp_Ln,p,2.0_cp); write(i_debug,*) 'L2(p_post_modify_RHS) = ',temp_Ln; endif
        if (i_stop) then; write(i_debug,*) 'mean(r_post_subtract_mean) = ',physical_mean(r); endif

        ! call apply_stitches(x,m) ! Necessary: BC_implicit reaches to interior, which stitching affects
        call operator(Ax,x,k,m,MFP,tempk)
        call multiply(Ax,vol)
        if (i_stop) then; write(i_debug,*) 'mean(Ax_before_loop) = ',physical_mean(Ax); endif
        ! if (i_stop) then; call Ln(temp_Ln,Ax,2.0_cp); write(i_debug,*) 'L2(Ax_before_loop) = ',temp_Ln; endif
        call subtract(r,Ax)
        ! if (i_stop) then; call Ln(temp_Ln,r,2.0_cp); write(i_debug,*) 'L2(r_post_subtract_mean) = ',temp_Ln; endif
        call compute(norm_res0,r)
#ifdef _EXPORT_PCG_SF_CONVERGENCE_
          call compute(norm,r)
          res_norm = dot_product(r,r,m,x,tempx)
          write(un,norm_fmt) N_iter,sqrt(res_norm)/norm_res0%L2,norm%L1,norm%L2,norm%Linf,&
                                            norm_res0%L1,norm_res0%L2,norm_res0%Linf,0
#endif

        call multiply(z,Minv,r)
        ! if (i_stop) then; call Ln(temp_Ln,Minv,2.0_cp); write(i_debug,*) 'L2(Minv) = ',temp_Ln; endif
        ! if (i_stop) then; call Ln(temp_Ln,z,2.0_cp); write(i_debug,*) 'L2(z_before_loop) = ',temp_Ln; endif
        call assign(p,z)
        ! if (i_stop) then; call Ln(temp_Ln,p,2.0_cp); write(i_debug,*) 'L2(p_before_loop) = ',temp_Ln; endif
        ! if (i_stop) then; call Ln(temp_Ln,r,2.0_cp); write(i_debug,*) 'L2(r_before_loop) = ',temp_Ln; endif
        rhok = dot_product(r,z,m,x,tempx); res_norm = rhok; i_earlyExit = 0
        do i=1,n
          ! if (x%all_Neumann) call subtract_physical_mean(p,vol,tempx,compute_norms)
          ! call apply_stitches(p,m)
          call operator(Ax,p,k,m,MFP,tempk)
          if (i_stop) then; write(i_debug,*) 'mean(p_in_loop) = ',physical_mean(p); endif
          if (i_stop) then; write(i_debug,*) 'mean(Ap_in_loop) = ',physical_mean(Ax); endif
          ! if (i_stop) then; call Ln(temp_Ln,Ax,2.0_cp); write(i_debug,*) 'L2(Ax) = ',temp_Ln; endif
          call multiply(Ax,vol)
          ! if (x%all_Neumann) call subtract_physical_mean(Ax)
          alpha = rhok/dot_product(p,Ax,m,x,tempx)
          call zeroGhostPoints(p)
          call add_product(x,p,alpha) ! x = x + alpha p
          call apply_BCs(x,m) ! Needed for PPE
          ! if (i_stop) then; call Ln(temp_Ln,x,2.0_cp); write(i_debug,*) 'L2(x_updated) = ',temp_Ln; endif
          N_iter = N_iter + 1
          call add_product(r,Ax,-alpha) ! r = r - alpha Ap
          ! if (i_stop) then; call Ln(temp_Ln,r,2.0_cp); write(i_debug,*) 'L2(r_updated) = ',temp_Ln; endif
          ! if (x%all_Neumann) call subtract_physical_mean(r)
          res_norm = dot_product(r,r,m,x,tempx)

#ifdef _EXPORT_PCG_SF_CONVERGENCE_
          call compute(norm,r)
          write(un,norm_fmt) N_iter,sqrt(res_norm)/norm_res0%L2,norm%L1,norm%L2,norm%Linf,&
                                            norm_res0%L1,norm_res0%L2,norm_res0%Linf,i
#endif
          if ((sqrt(res_norm)/norm_res0%L2.lt.tol).or.(sqrt(res_norm).lt.tol_abs)) then; i_earlyExit=1; exit; endif
          call multiply(z,Minv,r)
          rhokp1 = dot_product(z,r,m,x,tempx)
          call multiply(p,rhokp1/rhok) ! p = z + beta p
          ! if (i_stop) then; call Ln(temp_Ln,p,2.0_cp); write(i_debug,*) 'L2(p_updated) = ',temp_Ln; endif
          call add(p,z)
          rhok = rhokp1
        enddo

#ifdef _EXPORT_PCG_SF_CONVERGENCE_
        flush(un)
#endif
        ! if (i_stop) close(i_debug)

        if (compute_norms) then
          call operator_explicit(Ax,x,k,m,MFP,tempk)
          if (i_stop) then; write(i_debug,*) 'mean(Ax_explicit) = ',physical_mean(Ax); endif
          call multiply(Ax,vol)
          call multiply(r,b,vol)
          if (x%all_Neumann) call subtract_physical_mean(r)
          call subtract(r,Ax)
          call zeroWall_conditional(r,m,x) ! Does nothing in PPE
          call zeroGhostPoints(r)
          call compute(norm,r); call print(norm,'PCG_SF Residuals for '//name)
          write(un,norm_fmt) N_iter,sqrt(res_norm)/norm_res0%L2,norm%L1,norm%L2,norm%Linf,&
                                            norm_res0%L1,norm_res0%L2,norm_res0%Linf,i-1+i_earlyExit
          flush(un)
          write(*,*) 'PCG_SF iterations (executed/max) = ',i-1+i_earlyExit,n
          write(*,*) 'PCG_SF exit condition = ',sqrt(res_norm)/norm_res0%L2
          write(*,*) ''
        endif
        if (i_stop) write(i_debug,*) ' ************************* END PPE ************************* '
      end subroutine

      subroutine solve_PCG_VF(operator,operator_explicit,name,x,b,vol,k,m,&
        MFP,n,tol,norm,compute_norms,un,tempx,tempk,Ax,r,p,N_iter,z,Minv)
        implicit none
        external :: operator,operator_explicit
        character(len=1),intent(in) :: name
        type(VF),intent(inout) :: x
        type(VF),intent(in) :: b,vol,Minv
        type(VF),intent(in) :: k
        type(VF),intent(inout) :: tempk
        type(mesh),intent(in) :: m
        type(norms),intent(inout) :: norm
        integer,intent(in) :: n
        real(cp),intent(in) :: tol
        integer,intent(inout) :: N_iter
        integer,intent(in) :: un
        logical,intent(in) :: compute_norms
        type(matrix_free_params),intent(in) :: MFP
        type(VF),intent(inout) :: tempx,Ax,r,p,z
        integer :: i,i_earlyExit
        type(norms) :: norm_res0
        real(cp) :: alpha,rhok,rhokp1,res_norm ! betak = rhokp1/rhok
        call multiply(r,b,vol)
        ! ----------------------- MODIFY RHS -----------------------
        ! THE FOLLOWING MODIFICATION SHOULD BE READ VERY CAREFULLY.
        ! MODIFCATIONS ARE EXPLAINED IN DOCUMENTATION.
        call assign(p,r)
        call modify_forcing1(r,p,m,x)
        call assign(p,0.0_cp)
        call apply_BCs(p,m) ! p has BCs for x
        call zeroGhostPoints_conditional(p,m)
        call operator_explicit(Ax,p,k,m,MFP,tempk)
        call multiply(Ax,vol)
        call zeroGhostPoints(Ax)
        call zeroWall_conditional(Ax,m,x)
        call subtract(r,Ax)
        ! ----------------------------------------------------------

        call operator(Ax,x,k,m,MFP,tempk)
        call multiply(Ax,vol)
        ! if (x%all_Neumann) call subtract_physical_mean(r)
        call subtract(r,Ax)
        call compute(norm_res0,r)
#ifdef _EXPORT_PCG_VF_CONVERGENCE_
          call compute(norm,r)
          res_norm = dot_product(r,r,m,x,tempx)
          write(un,norm_fmt) N_iter,sqrt(res_norm)/norm_res0%L2,norm%L1,norm%L2,norm%Linf,&
                                            norm_res0%L1,norm_res0%L2,norm_res0%Linf,0
#endif

        call multiply(z,Minv,r)
        call assign(p,z)
        rhok = dot_product(r,z,m,x,tempx); res_norm = rhok; i_earlyExit = 0
        do i=1,n
          call apply_stitches(p,m)
          call operator(Ax,p,k,m,MFP,tempk)
          call multiply(Ax,vol)
          alpha = rhok/dot_product(p,Ax,m,x,tempx)
          call add_product(x,p,alpha) ! x = x + alpha p
          call apply_BCs(x,m) ! Needed for PPE
          N_iter = N_iter + 1
          call add_product(r,Ax,-alpha) ! x = x - alpha Ap
          res_norm = dot_product(r,r,m,x,tempx)

#ifdef _EXPORT_PCG_VF_CONVERGENCE_
          call compute(norm,r)
          write(un,norm_fmt) N_iter,sqrt(res_norm)/norm_res0%L2,norm%L1,norm%L2,norm%Linf,&
                                            norm_res0%L1,norm_res0%L2,norm_res0%Linf,i
#endif
          if ((sqrt(res_norm)/norm_res0%L2.lt.tol).or.(sqrt(res_norm).lt.tol_abs)) then; i_earlyExit=1; exit; endif

          call multiply(z,Minv,r)
          rhokp1 = dot_product(z,r,m,x,tempx)
          call multiply(p,rhokp1/rhok) ! p = z + beta p
          call add(p,z)
          call zeroGhostPoints(p)
          rhok = rhokp1
        enddo

#ifdef _EXPORT_PCG_VF_CONVERGENCE_
        flush(un)
#endif
        
        if (compute_norms) then
          call operator_explicit(Ax,x,k,m,MFP,tempk)
          call multiply(Ax,vol)
          call multiply(r,b,vol)
          ! if (x%all_Neumann) call subtract_physical_mean(r)
          call subtract(r,Ax)
          call zeroWall_conditional(r,m,x)
          call zeroGhostPoints(r)
          call compute(norm,r); call print(norm,'PCG_VF Residuals for '//name)
          write(un,norm_fmt) N_iter,sqrt(res_norm)/norm_res0%L2,norm%L1,norm%L2,norm%Linf,&
                                            norm_res0%L1,norm_res0%L2,norm_res0%Linf,i-1+i_earlyExit
          flush(un)
          write(*,*) 'PCG_VF iterations (executed/max) = ',i-1+i_earlyExit,n
          write(*,*) 'PCG_VF exit condition = ',sqrt(res_norm)/norm_res0%L2
          write(*,*) ''
        endif
      end subroutine

      end module