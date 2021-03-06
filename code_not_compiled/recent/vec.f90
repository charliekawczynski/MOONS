      module vec_mod
      ! Stores elements of a scalar field (SF) in a 1D array.
      use current_precision_mod
      use array_mod
      use SF_mod
      implicit none

      private
      public :: vec
      public :: init,delete
      public :: print,check

      type vec
        type(array) :: a
      end type

      interface init;       module procedure init_vec;              end interface
      interface init;       module procedure init_SF_vec;           end interface
      interface init;       module procedure init_Copy;             end interface
      interface delete;     module procedure delete_vec;            end interface
      interface print;      module procedure print_vec;             end interface

      contains

      subroutine init_vec(v,f)
        implicit none
        type(vec),intent(inout) :: v
        type(SF),intent(in) :: f
        integer :: i,j,k,t
        type(array) :: temp1,temp2
        do t=1,f%s; do k=1,f%RF(t)%s(3); do j=1,f%RF(t)%s(2)
          call init(temp1,v%a)
          call init(temp2,f%RF(t)%f(:,i,j))
          call init(v%a,(/temp1,temp2/))
        enddo; enddo; enddo
        call delete(temp1)
        call delete(temp2)
      end subroutine

      subroutine init_SF_vec(f,v)
        implicit none
        type(SF),intent(inout) :: f
        type(vec),intent(in) :: v
        integer :: i,j,k,t,m1,m2
        if (.not.allocated(f%RF(1)%f)) stop 'Error: f not allocated in init_SF_vec in vec.f90'
        m1 = 1; m2 = f%RF(1)%s(1)
        do t=1,f%s; do k=1,f%RF(t)%s(3); do j=1,f%RF(t)%s(2)
          f%RF(t)%f(:,i,j) = v%a(m1:m2)
          m1 = m2+1
          m2 = f%RF(t)%s(1)
        enddo; enddo; enddo
      end subroutine

      subroutine delete_vec(v)
        implicit none
        type(vec),intent(inout) :: v
        call delete(v%a)
      end subroutine

      subroutine init_Copy(v_out,v_in)
        implicit none
        type(vec),intent(inout) :: v_out
        type(vec),intent(in) :: v_in
        integer :: i
        call init(v_out%a,v_in%a)
      end subroutine

      subroutine print_vec(v)
        implicit none
        type(vec),intent(in) :: v
        call print(v%a)
      end subroutine

      end module
