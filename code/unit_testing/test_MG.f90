       module modelProblem_mod
       use grid_mod
       use BCs_mod
       use SF_mod
       use applyBCs_mod
       use ops_discrete_mod
       use ops_aux_mod
       implicit none
       private

       public :: get_ModelProblem,defineSig

       ! integer,parameter :: modelProblem = 1

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

       real(cp),parameter :: PI = 4.0_cp*atan(1.0_cp)

       contains

       subroutine defineBCs(u_bcs,g,s,bctype)
         implicit none
         type(BCs),intent(inout) :: u_bcs
         integer,dimension(3),intent(in) :: s
         integer,intent(in) :: bctype
         type(grid),intent(in) :: g
         ! bctype = 1 ! Dirichlet
         !          2 ! Neumann
         call init(u_bcs,g,s)
         if (bctype.eq.1) then
          call init_Dirichlet(u_bcs)
         elseif (bctype.eq.2) then
          call init_Neumann(u_bcs)
         else; stop 'Error: bctype must = 1,2 in test_MG.f90'
         endif
         call init(u_bcs,0.0_cp)
       end subroutine

       subroutine defineFunction(u,x,y,z,bctype)
         implicit none
         type(SF),intent(inout) :: u
         real(cp),dimension(:),intent(in) :: x,y,z
         integer,intent(in) :: bctype
         integer :: i,j,k,t,nmodes
         real(cp),dimension(3) :: p
         integer,dimension(3) :: s
         s = u%RF(1)%s

         call assign(u,0.0_cp)
         nmodes = 1
         do t=1,nmodes
           select case (bctype)
           case (1); p = 3.0_cp
           case (2); p = 2.0_cp
           case default
           stop 'Error: bctype must = 1,2 in defineFunction in poisson.f90'
           end select

           p = p*real(t,cp)

           if (bctype.eq.2) then
             do k = 1,s(3); do j = 1,s(2); do i = 1,s(1)
             u%RF(1)%f(i,j,k) = u%RF(1)%f(i,j,k) +(cos(p(1)*PI*x(i))*&
                                                   cos(p(2)*PI*y(j))*&
                                                   cos(p(3)*PI*z(k)))/real(t,cp)
             enddo;enddo;enddo
           elseif (bctype.eq.1) then
             do k = 1,s(3); do j = 1,s(2); do i = 1,s(1)
             u%RF(1)%f(i,j,k) = u%RF(1)%f(i,j,k) +(sin(p(1)*PI*x(i))*&
                                                   sin(p(2)*PI*y(j))*&
                                                   sin(p(3)*PI*z(k)))/real(t,cp)
             enddo;enddo;enddo
           endif
         enddo

         ! call zeroGhostPoints(u)        ! Necessary for BOTH Dirichlet problems AND Neumann
       end subroutine

       subroutine get_ModelProblem(g,f,u,u_exact)
         implicit none
         type(grid),intent(in) :: g
         type(SF),intent(inout) :: u,u_exact,f
         integer :: i
         integer,dimension(3) :: s
         integer :: bctype
         s = f%RF(1)%s

         bctype = 1 ! Dirichlet
         ! bctype = 2 ! Neumann
         call defineBCs(u%RF(1)%b,g,s,bctype)
         call defineBCs(u_exact%RF(1)%b,g,s,bctype)
         call defineBCs(f%RF(1)%b,g,s,bctype)

         ! Node data
         if (all((/(g%c(i)%sn.eq.s(i),i=1,3)/))) then
           call defineFunction(u_exact,g%c(1)%hn,g%c(2)%hn,g%c(3)%hn,bctype)

           ! CC data
         elseif (all((/(g%c(i)%sc.eq.s(i),i=1,3)/))) then
           call defineFunction(u_exact,g%c(1)%hc,g%c(2)%hc,g%c(3)%hc,bctype)

           ! Face data
         elseif (all((/g%c(1)%sn.eq.s(1),g%c(2)%sc.eq.s(2),g%c(3)%sc.eq.s(3)/))) then
           call defineFunction(u_exact,g%c(1)%hn,g%c(2)%hc,g%c(3)%hc,bctype)
         elseif (all((/g%c(1)%sc.eq.s(1),g%c(2)%sn.eq.s(2),g%c(3)%sc.eq.s(3)/))) then
           call defineFunction(u_exact,g%c(1)%hc,g%c(2)%hn,g%c(3)%hc,bctype)
         elseif (all((/g%c(1)%sc.eq.s(1),g%c(2)%sc.eq.s(2),g%c(3)%sn.eq.s(3)/))) then
           call defineFunction(u_exact,g%c(1)%hc,g%c(2)%hc,g%c(3)%hn,bctype)

           ! Edge data
         elseif (all((/g%c(1)%sc.eq.s(1),g%c(2)%sn.eq.s(2),g%c(3)%sn.eq.s(3)/))) then
           call defineFunction(u_exact,g%c(1)%hc,g%c(2)%hn,g%c(3)%hn,bctype)
         elseif (all((/g%c(1)%sn.eq.s(1),g%c(2)%sc.eq.s(2),g%c(3)%sn.eq.s(3)/))) then
           call defineFunction(u_exact,g%c(1)%hn,g%c(2)%hc,g%c(3)%hn,bctype)
         elseif (all((/g%c(1)%sn.eq.s(1),g%c(2)%sn.eq.s(2),g%c(3)%sc.eq.s(3)/))) then
           call defineFunction(u_exact,g%c(1)%hn,g%c(2)%hn,g%c(3)%hc,bctype)
         else
          stop 'Error: Bad sizes in defineBCs in poisson.f90'
         endif

         ! f must reach to ghost nodes, which must be defined
         call applyAllBCs(u_exact,g)
         call lap(f,u_exact,g)

         ! If Dirichlet, apply BCs to u so u = u_exact
         ! on boundary, otherwise make f satisfy BCs
         if (bctype.eq.1) then
               call applyAllBCs(u,g)
         else; call applyAllBCs(f,g)
         endif
       end subroutine

       subroutine defineSig(sig)
         implicit none
         type(SF),intent(inout) :: sig
         integer :: i,j,k
         integer,dimension(3) :: s
         logical,dimension(3) :: TF
         integer :: frac
         s = sig%RF(1)%s
         frac = 3
         do k=1,s(3); do j=1,s(2); do i=1,s(1)
         TF(1) = (i.gt.s(1)/frac).and.(i.lt.s(1) - s(1)/frac)
         TF(2) = (j.gt.s(2)/frac).and.(j.lt.s(2) - s(2)/frac)
         TF(3) = (k.gt.s(3)/frac).and.(k.lt.s(3) - s(3)/frac)
         if (all(TF)) sig%RF(1)%f(i,j,k) = 0.01_cp
         enddo; enddo; enddo

       end subroutine

       end module

       module unit_test_mod
       use simParams_mod
       use IO_SF_mod
       use grid_mod
       use norms_mod
       use ops_discrete_mod
       use BCs_mod
       use applyBCs_mod
       use MG_mod
       use SF_mod
       use VF_mod
       use gridGen_mod
       use gridGenTools_mod
       use solverSettings_mod
       use ops_interp_mod
       use ops_aux_mod

       use modelProblem_mod

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

       contains

       subroutine unit_test(dir)
         implicit none
         character(len=*),intent(in) :: dir
         type(grid) :: g
         integer,dimension(3) :: N = 2**6 ! Number of cells
         real(cp),dimension(3) :: hmin,hmax
         type(MGSolver),dimension(3) :: MG
         character(len=3) :: name
         type(norms) :: norm_res,norm_e
         type(solverSettings) :: ss
         type(gridGenerator) :: gg
         type(SF) :: u,u_exact,f,lapU,e,R,sig
         type(VF) :: sigma,temp

         write(*,*) 'Number of cells = ',N

         hmin = 0.0_cp; hmax = 1.0_cp
         call init(gg,(/uniform(hmin(1),hmax(1),N(1))/),1)
         call init(gg,(/uniform(hmin(2),hmax(2),N(2))/),2)
         call init(gg,(/uniform(hmin(3),hmax(3),N(3))/),3)
         call applyGhost(gg)
         call init(g,gg%g)
         call init_stencils(g)

         call export(g,dir,'g_base')

         call init(ss)
         call setName(ss,'Lap(u) = f          ')

         ! *************************************************************
         ! ****************** PARAMETERS TO DEFINE *********************
         ! *************************************************************

         call init_CC(u,g)
         call init_Face(sigma,g)
         call init(sig,u)
         call init(temp,sigma)

         call assign(sig,1.0_cp)
         call defineSig(sig)
         call cellCenter2Face(sigma,sig,g)

         call init(e,u)
         call init(R,u)
         call init(u_exact,u)
         call init(f,u)
         call init(lapU,u)

         write(*,*) 'Before model problem'
         call get_ModelProblem(g,f,u,u_exact)
         write(*,*) 'after model problem'
         write(*,*) 'Model problem finished!'

         call export_1C_SF(g,u_exact,dir,'u_exact',0)
         call export_1C_SF(g,f,dir,'f',0)
         call export_1C_SF(g,sig,dir,'sigma',0)

         ! *************************************************************
         ! *************************************************************
         ! *************************************************************

         name = 'MG '
         ! call setMaxIterations(ss,6000) ! Cell centered data
         call assign(u,0.0_cp)
         call init(MG,u,g,sigma,ss,.true.)
         call testRP(MG,f,dir)
         ! call solve(MG,u,f,sigma,g,ss,norm_res,.true.)
         call delete(MG)
         call compute_Au(lapU,u,sigma,g,temp)
         call subtract(e,u,u_exact)
         call subtract(R,lapU,f)
         call zeroGhostPoints(R)
         call export_1C_SF(g,R,dir,'R_'//name,0)
         call export_1C_SF(g,u,dir,'u_'//name,0)
         call export_1C_SF(g,e,dir,'e_'//name,0)
         call subtract(u,u_exact)
         call compute(norm_e,u,g)
         call print(norm_e,'u_'//name//' vs u_exact')

         call delete(g)
         call delete(e)
         call delete(u)
         call delete(sigma)
         call delete(sig)
         call delete(f)
         call delete(temp)
         call delete(u_exact)
         call delete(lapU)
         call delete(R)
       end subroutine

       end module
