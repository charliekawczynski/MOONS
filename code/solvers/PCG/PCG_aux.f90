      module PCG_aux_mod
      use current_precision_mod
      use mesh_mod
      use SF_mod
      use VF_mod
      implicit none

      private

      public :: modify_forcing1
      interface modify_forcing1;             module procedure modify_forcing1_SF;              end interface
      interface modify_forcing1;             module procedure modify_forcing1_VF;              end interface

      public :: zeroGhostPoints_conditional
      interface zeroGhostPoints_conditional; module procedure zeroGhostPoints_conditional_SF;  end interface
      interface zeroGhostPoints_conditional; module procedure zeroGhostPoints_conditional_VF;  end interface

      public :: assign_ghost_if_periodic
      interface assign_ghost_if_periodic;    module procedure assign_ghost_if_periodic_SF;     end interface
      interface assign_ghost_if_periodic;    module procedure assign_ghost_if_periodic_VF;     end interface

      contains

      subroutine modify_forcing1_SF(f_mod,f,m,x)
        implicit none
        type(SF),intent(inout) :: f_mod
        type(SF),intent(in) :: f
        type(mesh),intent(in) :: m
        type(SF),intent(in) :: x
        integer :: i
        if (f%N_along(1).and.(.not.m%plane_x)) then
          do i=1,m%s
            if (.not.m%g(i)%st_faces(1)%TF) then
              if (x%RF(i)%b%f(1)%b%Neumann) then
                f_mod%RF(i)%f(2,:,:) = f%RF(i)%f(2,:,:)/2.0_cp
              elseif (x%RF(i)%b%f(1)%b%Dirichlet) then
                f_mod%RF(i)%f(2,:,:) = 0.0_cp
              endif
            endif
            if (.not.m%g(i)%st_faces(2)%TF) then
              if (x%RF(i)%b%f(2)%b%Neumann) then
                f_mod%RF(i)%f(f%RF(i)%s(1)-1,:,:) = f%RF(i)%f(f%RF(i)%s(1)-1,:,:)/2.0_cp
              elseif (x%RF(i)%b%f(2)%b%Dirichlet) then
                f_mod%RF(i)%f(f%RF(i)%s(1)-1,:,:) = 0.0_cp
              endif
            endif
          enddo
        endif
        if (f%N_along(2).and.(.not.m%plane_y)) then
          do i=1,m%s
            if (.not.m%g(i)%st_faces(3)%TF) then
              if (x%RF(i)%b%f(3)%b%Neumann) then
                f_mod%RF(i)%f(:,2,:) = f%RF(i)%f(:,2,:)/2.0_cp
              elseif (x%RF(i)%b%f(3)%b%Dirichlet) then
                f_mod%RF(i)%f(:,2,:) = 0.0_cp
              endif
            endif
            if (.not.m%g(i)%st_faces(4)%TF) then
              if (x%RF(i)%b%f(4)%b%Neumann) then
                f_mod%RF(i)%f(:,f%RF(i)%s(2)-1,:) = f%RF(i)%f(:,f%RF(i)%s(2)-1,:)/2.0_cp
              elseif (x%RF(i)%b%f(4)%b%Dirichlet) then
                f_mod%RF(i)%f(:,f%RF(i)%s(2)-1,:) = 0.0_cp
              endif
            endif
          enddo
        endif
        if (f%N_along(3).and.(.not.m%plane_z)) then
          do i=1,m%s
            if (.not.m%g(i)%st_faces(5)%TF) then
              if (x%RF(i)%b%f(5)%b%Neumann) then
                f_mod%RF(i)%f(:,:,2) = f%RF(i)%f(:,:,2)/2.0_cp
              elseif (x%RF(i)%b%f(5)%b%Dirichlet) then
                f_mod%RF(i)%f(:,:,2) = 0.0_cp
              endif
            endif
            if (.not.m%g(i)%st_faces(6)%TF) then
              if (x%RF(i)%b%f(6)%b%Neumann) then
                f_mod%RF(i)%f(:,:,f%RF(i)%s(3)-1) = f%RF(i)%f(:,:,f%RF(i)%s(3)-1)/2.0_cp
              elseif (x%RF(i)%b%f(6)%b%Dirichlet) then
                f_mod%RF(i)%f(:,:,f%RF(i)%s(3)-1) = 0.0_cp
              endif
            endif
          enddo
        endif
      end subroutine

      subroutine assign_ghost_if_periodic_SF(xg,x,m)
        implicit none
        type(SF),intent(inout) :: xg
        type(SF),intent(in) :: x
        type(mesh),intent(in) :: m
        integer :: i
        if (x%CC_along(1).and.(.not.m%plane_x)) then
        do i=1,m%s
          if (.not.m%g(i)%st_faces(1)%TF.and.xg%RF(i)%b%f(1)%b%periodic) then
            xg%RF(i)%f(1,:,:) = x%RF(i)%f(1,:,:)
          endif
          if (.not.m%g(i)%st_faces(2)%TF.and.xg%RF(i)%b%f(2)%b%periodic) then
            xg%RF(i)%f(xg%RF(i)%s(1),:,:) = x%RF(i)%f(x%RF(i)%s(1),:,:)
          endif
        enddo
        endif
        if (x%CC_along(2).and.(.not.m%plane_y)) then
        do i=1,m%s
          if (.not.m%g(i)%st_faces(3)%TF.and.xg%RF(i)%b%f(3)%b%periodic) then
            xg%RF(i)%f(:,1,:) = x%RF(i)%f(:,1,:)
          endif
          if (.not.m%g(i)%st_faces(4)%TF.and.xg%RF(i)%b%f(4)%b%periodic) then
            xg%RF(i)%f(:,xg%RF(i)%s(2),:) = x%RF(i)%f(:,x%RF(i)%s(2),:)
          endif
        enddo
        endif
        if (x%CC_along(3).and.(.not.m%plane_z)) then
        do i=1,m%s
          if (.not.m%g(i)%st_faces(5)%TF.and.xg%RF(i)%b%f(5)%b%periodic) then
            xg%RF(i)%f(:,:,1) = x%RF(i)%f(:,:,1)
          endif
          if (.not.m%g(i)%st_faces(6)%TF.and.xg%RF(i)%b%f(6)%b%periodic) then
            xg%RF(i)%f(:,:,xg%RF(i)%s(3)) = x%RF(i)%f(:,:,x%RF(i)%s(3))
          endif
        enddo
        endif
      end subroutine

      subroutine modify_forcing1_VF(f_mod,f,m,x)
        implicit none
        type(VF),intent(inout) :: f_mod
        type(VF),intent(in) :: f
        type(mesh),intent(in) :: m
        type(VF),intent(in) :: x
        call modify_forcing1_SF(f_mod%x,f%x,m,x%x)
        call modify_forcing1_SF(f_mod%y,f%y,m,x%y)
        call modify_forcing1_SF(f_mod%z,f%z,m,x%z)
      end subroutine

      subroutine assign_ghost_if_periodic_VF(xg,x,m)
        implicit none
        type(VF),intent(inout) :: xg
        type(VF),intent(in) :: x
        type(mesh),intent(in) :: m
        call assign_ghost_if_periodic_SF(xg%x,x%x,m)
        call assign_ghost_if_periodic_SF(xg%y,x%y,m)
        call assign_ghost_if_periodic_SF(xg%z,x%z,m)
      end subroutine

      subroutine zeroGhostPoints_conditional_SF(x,m)
        implicit none
        type(SF),intent(inout) :: x
        type(mesh),intent(in) :: m
        integer :: i
        if (x%N_along(1)) then
          do i=1,m%s
            if ((.not.m%g(i)%st_faces(1)%TF).and.(.not.x%RF(i)%b%f(1)%b%periodic)) x%RF(i)%f(1,:,:) = 0.0_cp
            if ((.not.m%g(i)%st_faces(2)%TF).and.(.not.x%RF(i)%b%f(2)%b%periodic)) x%RF(i)%f(x%RF(i)%s(1),:,:) = 0.0_cp
          enddo
        endif
        if (x%N_along(2)) then
          do i=1,m%s
            if ((.not.m%g(i)%st_faces(3)%TF).and.(.not.x%RF(i)%b%f(3)%b%periodic)) x%RF(i)%f(:,1,:) = 0.0_cp
            if ((.not.m%g(i)%st_faces(4)%TF).and.(.not.x%RF(i)%b%f(4)%b%periodic)) x%RF(i)%f(:,x%RF(i)%s(2),:) = 0.0_cp
          enddo
        endif
        if (x%N_along(3)) then
          do i=1,m%s
            if ((.not.m%g(i)%st_faces(5)%TF).and.(.not.x%RF(i)%b%f(5)%b%periodic)) x%RF(i)%f(:,:,1) = 0.0_cp
            if ((.not.m%g(i)%st_faces(6)%TF).and.(.not.x%RF(i)%b%f(6)%b%periodic)) x%RF(i)%f(:,:,x%RF(i)%s(3)) = 0.0_cp
          enddo
        endif
      end subroutine

      subroutine zeroGhostPoints_conditional_VF(x,m)
        implicit none
        type(VF),intent(inout) :: x
        type(mesh),intent(in) :: m
        call zeroGhostPoints_conditional_SF(x%x,m)
        call zeroGhostPoints_conditional_SF(x%y,m)
        call zeroGhostPoints_conditional_SF(x%z,m)
      end subroutine

      end module