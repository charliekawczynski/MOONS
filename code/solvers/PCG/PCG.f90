      module PCG_mod
      use IO_SF_mod
      use mesh_mod
      use apply_BCs_mod
      use norms_mod
      use ops_discrete_mod
      use ops_aux_mod
      use SF_mod
      use VF_mod
      use IO_tools_mod
      use export_raw_processed_mod

      use preconditioners_mod
      use matrix_mod
      use PCG_solver_mod
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
      public :: PCG_solver_SF
      public :: PCG_solver_VF
      public :: init,solve,delete

      logical :: verifyPreconditioner = .false.
      
      interface init;    module procedure init_PCG_SF;   end interface
      interface init;    module procedure init_PCG_VF;   end interface

      interface solve;   module procedure solve_PCG_SF;  end interface
      interface solve;   module procedure solve_PCG_VF;  end interface

      interface delete;  module procedure delete_PCG_SF; end interface
      interface delete;  module procedure delete_PCG_VF; end interface

      type PCG_solver_SF
        type(matrix_free_params) :: MFP
        type(VF) :: tempk,k
        type(norms) :: norm
        type(SF) :: r,p,tempx,Ax,vol,z,Minv
        integer :: un,N_iter
        procedure(),pointer,nopass :: operator,operator_explicit
      end type

      type PCG_solver_VF
        type(matrix_free_params) :: MFP
        type(VF) :: tempk,k
        type(norms) :: norm
        type(VF) :: r,p,tempx,Ax,vol,z,Minv
        integer,dimension(3) :: un
        procedure(),pointer,nopass :: operator,operator_explicit
        integer :: N_iter
      end type

      contains

      subroutine init_PCG_SF(PCG,operator,operator_explicit,Minv,m,MFP,&
        x,k,dir,name,testSymmetry,exportOperator)
        implicit none
        external :: operator,operator_explicit
        type(PCG_solver_SF),intent(inout) :: PCG
        type(SF),intent(in) :: Minv
        type(mesh),intent(in) :: m
        type(SF),intent(in) :: x
        type(VF),intent(in) :: k
        character(len=*),intent(in) :: dir,name
        logical,intent(in) :: testSymmetry,exportOperator
        type(matrix_free_params),intent(in) :: MFP
        type(SF) :: temp_Minv
        call init(PCG%r,x)
        call init(PCG%p,x)
        call init(PCG%tempx,x)
        call init(PCG%Ax,x)
        call init(PCG%vol,x)
        call init(PCG%k,k)
        call init(PCG%tempk,k)
        call init(PCG%z,x)
        call init(PCG%Minv,x)
        call init(PCG%norm)
        call assign(PCG%k,k)
        call assign(PCG%Minv,Minv)
        call init(PCG%MFP,MFP)
        call volume(PCG%vol,m)
        PCG%un = newAndOpen(dir,'norm_PCG_'//name)
        call tecHeader(name,PCG%un,.false.)
        PCG%operator => operator
        PCG%operator_explicit => operator_explicit

        call init(temp_Minv,Minv)
        call assign(temp_Minv,PCG%Minv)
        if (verifyPreconditioner) then
          call export_raw(m,PCG%Minv,dir,'PCG_SF_prec_tec_'//name,0)
          call export_matrix(PCG%Minv,dir,'PCG_SF_prec_mat_'//name)
          call get_diagonal(operator_explicit,PCG%Minv,x,PCG%k,PCG%vol,m,MFP,PCG%tempk)
          call export_raw(m,PCG%Minv,dir,'PCG_SF_op_tec_diag_'//name,0)
          call export_matrix(PCG%Minv,dir,'PCG_SF_op_mat_diag_'//name)
        endif
        call assign(PCG%Minv,temp_Minv)
        call delete(temp_Minv)

        if (testSymmetry) then
          call test_symmetry(operator,'PCG_SF_'//name,x,PCG%k,PCG%vol,m,MFP,PCG%tempk)
        endif
        if (exportOperator) then
          call export_operator(operator,'PCG_SF_'//name,dir,x,PCG%k,PCG%vol,m,MFP,PCG%tempk)
          call export_matrix(PCG%Minv,dir,'PCG_SF_diag_'//name)
        endif
        PCG%N_iter = 1
      end subroutine

      subroutine init_PCG_VF(PCG,operator,operator_explicit,Minv,m,MFP,&
        x,k,dir,name,testSymmetry,exportOperator)
        implicit none
        external :: operator,operator_explicit
        type(PCG_solver_VF),intent(inout) :: PCG
        type(VF),intent(in) :: Minv
        type(mesh),intent(in) :: m
        type(VF),intent(in) :: x,k
        character(len=*),intent(in) :: dir,name
        logical,intent(in) :: testSymmetry,exportOperator
        type(matrix_free_params),intent(in) :: MFP
        type(VF) :: temp_Minv
        call init(PCG%r,x)
        call init(PCG%p,x)
        call init(PCG%tempx,x)
        call init(PCG%Ax,x)
        call init(PCG%vol,x)
        call init(PCG%k,k)
        call init(PCG%tempk,k)
        call init(PCG%z,x)
        call init(PCG%Minv,x)
        call init(PCG%norm)
        call assign(PCG%k,k)
        call assign(PCG%Minv,Minv)
        call init(PCG%MFP,MFP)
        call volume(PCG%vol,m)
        PCG%un(1) = newAndOpen(dir,'norm_PCG_x_'//name)
        PCG%un(2) = newAndOpen(dir,'norm_PCG_y_'//name)
        PCG%un(3) = newAndOpen(dir,'norm_PCG_z_'//name)
        call tecHeader(name,PCG%un(1),.true.)
        call tecHeader(name,PCG%un(2),.true.)
        call tecHeader(name,PCG%un(3),.true.)
        PCG%operator => operator
        PCG%operator_explicit => operator_explicit

        call init(temp_Minv,Minv)
        call assign(temp_Minv,PCG%Minv)
        if (verifyPreconditioner) then
          call export_raw(m,PCG%Minv,dir,'PCG_VF_prec_tec_'//name,0)
          call export_matrix(PCG%Minv,dir,'PCG_VF_prec_mat_'//name)
          call get_diagonal(operator_explicit,PCG%Minv,x,PCG%k,PCG%vol,m,MFP,PCG%tempk)
          call export_raw(m,PCG%Minv,dir,'PCG_VF_op_tec_diag_'//name,0)
          call export_matrix(PCG%Minv,dir,'PCG_VF_op_mat_diag_'//name)
        endif
        call assign(PCG%Minv,temp_Minv)
        call delete(temp_Minv)

        if (testSymmetry) then
          call test_symmetry(operator,'PCG_VF_'//name,x,PCG%k,PCG%vol,m,MFP,PCG%tempk)
        endif
        if (exportOperator) then
          call export_operator(operator_explicit,'PCG_VF_op_mat_'//name,dir,x,PCG%k,PCG%vol,m,MFP,PCG%tempk)
        endif
        PCG%N_iter = 1
      end subroutine

      subroutine solve_PCG_SF(PCG,x,b,m,n,compute_norms)
        implicit none
        type(PCG_solver_SF),intent(inout) :: PCG
        type(SF),intent(inout) :: x
        type(SF),intent(in) :: b
        type(mesh),intent(in) :: m
        integer,intent(in) :: n
        logical,intent(in) :: compute_norms
        call solve_PCG(PCG%operator,PCG%operator_explicit,x,b,PCG%vol,PCG%k,m,PCG%MFP,n,PCG%norm,&
        compute_norms,PCG%un,PCG%tempx,PCG%tempk,PCG%Ax,PCG%r,PCG%p,PCG%N_iter,PCG%z,PCG%Minv)
      end subroutine

      subroutine solve_PCG_VF(PCG,x,b,m,n,compute_norms)
        implicit none
        type(PCG_solver_VF),intent(inout) :: PCG
        type(VF),intent(inout) :: x
        type(VF),intent(in) :: b
        type(mesh),intent(in) :: m
        integer,intent(in) :: n
        logical,intent(in) :: compute_norms
        call solve_PCG(PCG%operator,PCG%operator_explicit,x,b,PCG%vol,PCG%k,m,PCG%MFP,n,PCG%norm,&
        compute_norms,PCG%un,PCG%tempx,PCG%tempk,PCG%Ax,PCG%r,PCG%p,PCG%N_iter,PCG%z,PCG%Minv)
      end subroutine

      subroutine delete_PCG_SF(PCG)
        implicit none
        type(PCG_solver_SF),intent(inout) :: PCG
        call delete(PCG%r)
        call delete(PCG%p)
        call delete(PCG%tempx)
        call delete(PCG%Ax)
        call delete(PCG%vol)
        call delete(PCG%k)
        call delete(PCG%tempk)
        call delete(PCG%z)
        call delete(PCG%Minv)
        call delete(PCG%MFP)
        PCG%N_iter = 1
      end subroutine

      subroutine delete_PCG_VF(PCG)
        implicit none
        type(PCG_solver_VF),intent(inout) :: PCG
        call delete(PCG%r)
        call delete(PCG%p)
        call delete(PCG%tempx)
        call delete(PCG%Ax)
        call delete(PCG%vol)
        call delete(PCG%k)
        call delete(PCG%tempk)
        call delete(PCG%z)
        call delete(PCG%Minv)
        call delete(PCG%MFP)
        PCG%N_iter = 1
      end subroutine

      subroutine tecHeader(name,un,VF)
        implicit none
        character(len=*),intent(in) :: name
        integer,intent(in) :: un
        logical,intent(in) :: VF
        if (VF) then; write(un,*) 'TITLE = "PCG_VF residuals for '//name//'"'
        else;         write(un,*) 'TITLE = "PCG_SF residuals for '//name//'"'
        endif
        write(un,*) 'VARIABLES = N,L1,L2,Linf'
        write(un,*) 'ZONE DATAPACKING = POINT'
      end subroutine

      end module