        module vec_int_mod
        implicit none
        private

        ! Initialization / Deletion (allocate/deallocate)
        public :: vec_int
        public :: init,delete,display,print,export,import ! Essentials

        type vec_int
          integer :: s                          ! size
          integer,dimension(:),allocatable :: i ! field
        end type

        interface init;                     module procedure init_vec_size;           end interface
        interface init;                     module procedure init_vec_copy;           end interface
        interface delete;                   module procedure delete_vec;              end interface
        interface display;                  module procedure display_vec;             end interface
        interface print;                    module procedure print_vec;               end interface
        interface export;                   module procedure export_vec;              end interface
        interface import;                   module procedure import_vec;              end interface

        contains

        ! **********************************************************
        ! ********************* ESSENTIALS *************************
        ! **********************************************************

        subroutine init_vec_size(a,N)
          implicit none
          type(vec),intent(inout) :: a
          integer,intent(in) :: N
          if (allocated(a%i)) deallocate(a%i)
          allocate(a%i(N))
          a%s = N
        end subroutine

        subroutine init_vec_copy(f1,f2)
          implicit none
          type(vec),intent(inout) :: f1
          type(vec),intent(in) :: f2
          if (.not.allocated(f2%i)) stop 'Error: trying to copy unallocated vec in vec_int.f90'
          call delete(f1)
          allocate(f1%i(f2%s))
          f1%s = f1%s
        end subroutine

        subroutine delete_vec(a)
          implicit none
          type(vec),intent(inout) :: a
          if (allocated(a%i)) deallocate(a%i)
          a%s = 0
        end subroutine

        subroutine display_vec(a,un)
          implicit none
          type(vec),intent(in) :: a
          integer,intent(in) :: un
          integer :: i,j,k,t
          if (allocated(a%i)) then
            write(*,*) 'size(f) = ',a%s
            do t=1,a%s
              write(un,'(A2,I1,A4,1I15)') 'f('t') = ',a%i(t)
            enddo
          endif
        end subroutine

        subroutine print_vec(a)
          implicit none
          type(vec),intent(in) :: a
          call display(a,6)
        end subroutine

        subroutine export_vec(a,un)
          implicit none
          type(vec),intent(in) :: a
          integer,intent(in) :: un
          integer :: t
          if (allocated(a%i)) then
          write(un,*) 'a%s = '
          write(un,*) a%s
          do t=1,a%s; write(un,*) a%i(t); enddo
          else; stop 'Error: trying to export unallocated vec in export_vec in vec.f90'
          endif
        end subroutine

        subroutine import_vec(a,un)
          implicit none
          type(vec),intent(inout) :: a
          integer,intent(in) :: un
          integer :: t
          call delete(a)
          read(un,*) 
          read(un,*) a%s
          allocate(a%i(a%s))
          do t=1,a%s; read(un,*) a%i(t); enddo
        end subroutine

        ! **********************************************************
        ! **********************************************************
        ! **********************************************************
        end module