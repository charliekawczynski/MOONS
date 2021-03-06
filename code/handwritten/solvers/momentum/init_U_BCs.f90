       module init_U_BCs_mod
       use current_precision_mod
       use BC_funcs_mod
       use block_mod
       use block_extend_mod
       use grid_mod
       use block_extend_mod
       use mesh_extend_mod
       use boundary_conditions_extend_mod
       use GF_mod
       use block_field_mod
       use block_field_extend_mod
       use SF_extend_mod
       use VF_extend_mod
       use profile_funcs_mod
       use face_edge_corner_indexing_mod
       use sim_params_mod
       implicit none

       private
       public :: init_U_BCs

       contains

       subroutine init_U_BCs(U,m,SP)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         type(sim_params),intent(in) :: SP
         integer,dimension(3) :: periodic_dir
         integer :: preset_ID
         call init_BC_mesh(U%x,m) ! MUST COME BEFORE BVAL ASSIGNMENT
         call init_BC_mesh(U%y,m) ! MUST COME BEFORE BVAL ASSIGNMENT
         call init_BC_mesh(U%z,m) ! MUST COME BEFORE BVAL ASSIGNMENT

         call Dirichlet_BCs(U,m)

         preset_ID = SP%VS%U%BC
         periodic_dir = SP%GP%periodic_dir
         ! preset_ID = 1 ! manual override

         select case (preset_ID)
         case (0);
         case (1);  call LDC_at_ymax(U)
         case (2);  call LDC_at_ymax_symmetric_zmax(U)
         case (3);  call LDC_at_ymax_smooth(U,m)
         case (4);  call duct_flow_uniform_in_axial_out(U)
         case (5);  call duct_flow_uniform_in_FD_out(U)
         case (6);  call duct_flow_periodic_IO(U)
         case (7);  call duct_flow_FD_in_FD_out(U,m,1)
         case (8);  call channel_flow_uniform_in_FD_out(U)
         case (9);  call channel_flow_parabolic_in_FD_out(U,m,2)
         case (10); call cylinder_driven_cavity(U,m,1)
         case (11); call Tylers_geometry(U)
         case (12); call flow_over_2D_square(U)
         case (13); call LDC_4_domains(U)
         case (14); call duct_flow_2D_2domains(U)
         case (15); call LDC_9_domains(U)
         case (16); call LDC_at_ymax_symmetric_zmax(U)
                    call LDC_at_ymax_Shatrov_smooth(U,m)
         case (17); call LDC_at_ymax_symmetric_zmax(U)
                    call LDC_at_ymax_Leriche_smooth(U,m)
         case (18); call Taylor_Green_Vortex(U)
         case default; stop 'Error: bad preset_ID in init_UBCs.f90'
         end select
         call make_periodic(U,m,periodic_dir)
         call init_BC_props(U,SP%DP%c_w,SP%DP%Robin_coeff)
       end subroutine

       subroutine LDC_at_ymax(U)
         implicit none
         type(VF),intent(inout) :: U
         call init(U%x%BF(1)%BCs,1.0_cp,4)
       end subroutine

       subroutine LDC_at_ymax_smooth(U,m)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         real(cp) :: n
         call init(U%x%BF(1)%BCs,1.0_cp,4)
         n = 18.0_cp
         ! smooth_lid_GF(U,g,DL,plane,n)
         call smooth_lid(U%x%BF(1)%BCs%face%SB(4)%b,m%B(1)%fb(4),U%x%DL,2,n)
       end subroutine

       subroutine LDC_at_ymax_Shatrov_smooth(U,m)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         real(cp) :: k_lid
         call init(U%x%BF(1)%BCs,1.0_cp,4)
         k_lid = 80.0_cp
         call smooth_lid_Shatrov(U%x%BF(1)%BCs%face%SB(4)%b,m%B(1)%fb(4),U%x%DL,2,k_lid)
       end subroutine

       subroutine LDC_at_ymax_Leriche_smooth(U,m)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         real(cp) :: n_lid
         call init(U%x%BF(1)%BCs,1.0_cp,4)
         n_lid = 18.0_cp
         call smooth_lid_Leriche(U%x%BF(1)%BCs%face%SB(4)%b,m%B(1)%fb(4),U%x%DL,2,n_lid,3)
       end subroutine

       subroutine Taylor_Green_Vortex(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i,j
         do i=1,U%x%s
         do j=1,6
         call init_periodic(U%z%BF(i)%BCs,j)
         enddo
         enddo
         do i=1,U%x%s
         call init_Neumann(U%x%BF(i)%BCs,1)
         call init_Neumann(U%x%BF(i)%BCs,2)
         call init_Dirichlet(U%x%BF(i)%BCs,3)
         call init_Dirichlet(U%x%BF(i)%BCs,4)
         call init_Neumann(U%y%BF(i)%BCs,3)
         call init_Neumann(U%y%BF(i)%BCs,4)
         call init_Dirichlet(U%y%BF(i)%BCs,1)
         call init_Dirichlet(U%y%BF(i)%BCs,2)
         enddo
       end subroutine

       subroutine LDC_at_ymax_symmetric_zmax(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i
         do i=1,U%x%s
         call init(U%x%BF(i)%BCs,1.0_cp,4)
         call init_Neumann(U%x%BF(i)%BCs,6)
         call init_Neumann(U%y%BF(i)%BCs,6)
         ! call init_Neumann(U%z%BF(i)%BCs,6) ! Results in small flow through
         call init_Dirichlet(U%z%BF(i)%BCs,6)
         enddo
       end subroutine

       subroutine LDC_4_domains(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i
         do i=1,U%x%s
         call init(U%x%BF(3)%BCs,1.0_cp,4) ! periodic in z, driven at ymax
         call init(U%x%BF(4)%BCs,1.0_cp,4) ! periodic in z, driven at ymax
         enddo
       end subroutine

       subroutine LDC_9_domains(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i
         do i=1,U%x%s
         call init(U%x%BF(5)%BCs,1.0_cp,4) ! periodic in z, driven at ymax
         call init(U%x%BF(8)%BCs,1.0_cp,4) ! periodic in z, driven at ymax
         call init(U%x%BF(9)%BCs,1.0_cp,4) ! periodic in z, driven at ymax
         ! call init(U%x%BF(5)%BCs%e(8+4),1.0_cp)
         ! call init(U%x%BF(8)%BCs%e(8+2),1.0_cp)
         ! call init(U%x%BF(8)%BCs%e(8+4),1.0_cp)
         ! call init(U%x%BF(9)%BCs%e(8+2),1.0_cp)
         enddo
       end subroutine

       subroutine duct_flow_uniform_in_FD_out(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i
         do i=1,U%x%s
         call init(U%x%BF(i)%BCs,1.0_cp,1)  ! Inlet (uniform)
         call init_Neumann(U%x%BF(i)%BCs,2) ! Outlet (fully developed)
         call init_Neumann(U%y%BF(i)%BCs,2) ! Outlet (fully developed)
         call init_Neumann(U%z%BF(i)%BCs,2) ! Outlet (fully developed)
         enddo
       end subroutine

       subroutine duct_flow_uniform_in_axial_out(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i
         do i=1,U%x%s
         call init(U%x%BF(i)%BCs,1.0_cp,1)  ! Inlet (uniform)
         call init_Neumann(U%x%BF(i)%BCs,2) ! Outlet (fully developed)
         enddo
       end subroutine

       subroutine duct_flow_periodic_IO(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i
         do i=1,U%x%s
         call init_periodic(U%x%BF(i)%BCs,1) ! Inlet (periodic)
         call init_periodic(U%x%BF(i)%BCs,2) ! Outlet (periodic)
         call init_periodic(U%y%BF(i)%BCs,1) ! Inlet (periodic)
         call init_periodic(U%y%BF(i)%BCs,2) ! Outlet (periodic)
         call init_periodic(U%z%BF(i)%BCs,1) ! Inlet (periodic)
         call init_periodic(U%z%BF(i)%BCs,2) ! Outlet (periodic)
         enddo
       end subroutine

       subroutine duct_flow_2D_2domains(U)
         implicit none
         type(VF),intent(inout) :: U
         ! Inlet (uniform)
         call init(U%x%BF(1)%BCs,1.0_cp,1)
         call init(U%x%BF(2)%BCs,1.0_cp,1)
         ! call init(U%x%BF(1)%BCs%e(8+2),1.0_cp)
         ! call init(U%x%BF(2)%BCs%e(8+1),1.0_cp)
         call init_Neumann(U%x%BF(1)%BCs,2) ! Outlet (fully developed)
         call init_Neumann(U%x%BF(2)%BCs,2) ! Outlet (fully developed)

       end subroutine

       subroutine channel_flow_uniform_in_FD_out(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i
         do i=1,U%x%s
         call init(U%x%BF(i)%BCs,1.0_cp,1)  ! Inlet (uniform)
         call init_Neumann(U%x%BF(i)%BCs,2) ! Outlet (fully developed)
         enddo
       end subroutine

       subroutine channel_flow_parabolic_in_FD_out(U,m,dir)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         integer,intent(in) :: dir
         integer :: i
         do i=1,U%x%s
         call parabolic_1D(U%x%BF(i)%BCs%face%SB(1)%b,m%B(1)%g,U%x%DL,dir) ! Inlet (parabolic)
         call init_Neumann(U%x%BF(i)%BCs,2) ! Outlet (fully developed)
         enddo
       end subroutine

       subroutine flow_over_2D_square(U)
         implicit none
         type(VF),intent(inout) :: U
         ! 16 edges total must be defined here with velocity of 1
         ! Inlet (uniform)
         call init(U%x%BF(1)%BCs,1.0_cp,1)
         call init(U%x%BF(2)%BCs,1.0_cp,1)
         call init(U%x%BF(3)%BCs,1.0_cp,1)
              ! Edges
              ! call init(U%x%BF(1)%BCs%e(8+1),1.0_cp); call init(U%x%BF(1)%BCs%e(8+2),1.0_cp)
              ! call init(U%x%BF(2)%BCs%e(8+1),1.0_cp); call init(U%x%BF(2)%BCs%e(8+2),1.0_cp)
              ! call init(U%x%BF(3)%BCs%e(8+1),1.0_cp); call init(U%x%BF(3)%BCs%e(8+2),1.0_cp)
         ! Sides (free-stream)
         call init(U%x%BF(2)%BCs,1.0_cp,4); call init(U%x%BF(3)%BCs,1.0_cp,3)
         call init(U%x%BF(4)%BCs,1.0_cp,4); call init(U%x%BF(6)%BCs,1.0_cp,3)
         call init(U%x%BF(5)%BCs,1.0_cp,4); call init(U%x%BF(7)%BCs,1.0_cp,3)
              ! Edges
              ! call init(U%x%BF(2)%BCs%e(8+4),1.0_cp); call init(U%x%BF(3)%BCs%e(8+3),1.0_cp)
              ! call init(U%x%BF(4)%BCs%e(8+2),1.0_cp); call init(U%x%BF(6)%BCs%e(8+1),1.0_cp)
              ! call init(U%x%BF(4)%BCs%e(8+4),1.0_cp); call init(U%x%BF(6)%BCs%e(8+3),1.0_cp)
              ! call init(U%x%BF(5)%BCs%e(8+2),1.0_cp); call init(U%x%BF(7)%BCs%e(8+1),1.0_cp)
              ! call init(U%x%BF(5)%BCs%e(8+4),1.0_cp); call init(U%x%BF(7)%BCs%e(8+3),1.0_cp)
         ! Outlet (fully developed and v=0)
         call init_Neumann(U%x%BF(5)%BCs,2)
         call init_Neumann(U%x%BF(7)%BCs,2)
         call init_Neumann(U%x%BF(8)%BCs,2)
       end subroutine

       subroutine Tylers_geometry(U)
         implicit none
         type(VF),intent(inout) :: U
         integer :: i
         ! THIS NEEDS TO BE FIXED
         do i=4,6
           call init_Neumann(U%x%BF(i)%BCs,2)
           call init_Neumann(U%y%BF(i)%BCs,2)
           call init_Neumann(U%z%BF(i)%BCs,2)
         enddo
         call init_Neumann(U%x%BF(10)%BCs,2); call init_Neumann(U%x%BF(14)%BCs,2)
         call init_Neumann(U%y%BF(10)%BCs,2); call init_Neumann(U%y%BF(14)%BCs,2)
         call init_Neumann(U%z%BF(10)%BCs,2); call init_Neumann(U%z%BF(14)%BCs,2)
         call init(U%x%BF(1)%BCs,1.0_cp,1)

         call init_Neumann(U%x%BF(1)%BCs,6)
         call init_Neumann(U%y%BF(1)%BCs,6)
         call init_Neumann(U%z%BF(1)%BCs,6)

         call init(U%x%BF(1)%BCs,1.0_cp,1)
         call init_Neumann(U%x%BF(14)%BCs,1)
         call init_Neumann(U%y%BF(14)%BCs,1)
         call init_Neumann(U%z%BF(14)%BCs,1)
       end subroutine

       subroutine cylinder_driven_cavity(U,m,face)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         integer,intent(in) :: face
         integer :: dir
         dir = dir_given_face(face)
         select case (dir)
         case(1); call cylinderDrivenBCs(U%y%BF(1),m%B(1),face,2)
                  call cylinderDrivenBCs(U%z%BF(1),m%B(1),face,3)
         case(2); call cylinderDrivenBCs(U%x%BF(1),m%B(1),face,1)
                  call cylinderDrivenBCs(U%z%BF(1),m%B(1),face,3)
         case(3); call cylinderDrivenBCs(U%x%BF(1),m%B(1),face,1)
                  call cylinderDrivenBCs(U%y%BF(1),m%B(1),face,2)
         end select
       end subroutine

       subroutine duct_flow_FD_in_FD_out(U,m,face)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         integer,intent(in) :: face
         integer :: dir
         dir = dir_given_face(face)
         select case (dir)
         case(1); call ductFlow_FD_Profile(U%x%BF(1),m%B(1),face)
         case(2); call ductFlow_FD_Profile(U%y%BF(1),m%B(1),face)
         case(3); call ductFlow_FD_Profile(U%z%BF(1),m%B(1),face)
         end select
       end subroutine

       subroutine cylinderDrivenBCs(BF,B,face,comp)
         implicit none
         type(block_field),intent(inout) :: BF
         type(block),intent(in) :: B
         integer,intent(in) :: face,comp
         integer,dimension(3) :: s
         integer,dimension(2) :: s_2D,a
         type(grid_field) :: temp
         real(cp) :: nhat
         integer :: dir
         dir = dir_given_face(face)
         nhat = nhat_given_face(face)
         a = adj_dir_given_dir(dir)
         s = BF%GF%s
         s(dir) = 1
         s_2D = (/s(a(1)),s(a(2))/)
         call init(temp,BF%GF)
         call assign(temp,reshape(rotatingCylinder(B%g%c(a(1)),&
                                                   B%g%c(a(2)),&
                                                   s(a(1)),&
                                                   s(a(2)),&
                                                   0.1_cp,1.0_cp,comp),s))
         call init(BF%BCs,temp,face)
         call multiply(temp,nhat)
         call delete(temp)
       end subroutine

       subroutine ductFlow_FD_Profile(BF,B,face)
         implicit none
         type(block_field),intent(inout) :: BF
         type(block),intent(in) :: B
         integer,intent(in) :: face
         integer,dimension(3) :: s
         integer,dimension(2) :: s_2D,a
         type(grid_field) :: temp
         real(cp) :: nhat
         integer :: dir
         dir = dir_given_face(face)
         nhat = nhat_given_face(face)
         a = adj_dir_given_dir(dir)
         s = BF%GF%s
         s(dir) = 1
         s_2D = (/s(a(1)),s(a(2))/)
         call init(temp,BF%GF)
         call assign(temp,reshape(init_FD_DuctFlow(B%g%c(a(1)),&
                                                   B%g%c(a(2)),&
                                                   s(a(1)),&
                                                   s(a(2))),s))
         call multiply(temp,nhat)
         call init(BF%BCs,temp,face)
         call delete(temp)
       end subroutine

       end module