       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module procedure_array_plane_op_mod
       use IO_tools_mod
       use single_procedure_plane_op_mod
       implicit none

       private
       public :: procedure_array_plane_op
       public :: init,delete,display,print,export,import
       public :: display_short,print_short

       interface init;         module procedure init_copy_procedure_array_plane_op;      end interface
       interface delete;       module procedure delete_procedure_array_plane_op;         end interface
       interface display;      module procedure display_procedure_array_plane_op;        end interface
       interface display_short;module procedure display_short_procedure_array_plane_op;  end interface
       interface display;      module procedure display_wrapper_procedure_array_plane_op;end interface
       interface print;        module procedure print_procedure_array_plane_op;          end interface
       interface print_short;  module procedure print_short_procedure_array_plane_op;    end interface
       interface export;       module procedure export_procedure_array_plane_op;         end interface
       interface import;       module procedure import_procedure_array_plane_op;         end interface
       interface export;       module procedure export_wrapper_procedure_array_plane_op; end interface
       interface import;       module procedure import_wrapper_procedure_array_plane_op; end interface

       type procedure_array_plane_op
         integer :: N = 0
         type(single_procedure_plane_op),dimension(:),allocatable :: SP
         logical :: defined = .false.
       end type

       contains

       subroutine init_copy_procedure_array_plane_op(this,that)
         implicit none
         type(procedure_array_plane_op),intent(inout) :: this
         type(procedure_array_plane_op),intent(in) :: that
         integer :: i_SP
         integer :: s_SP
         call delete(this)
         this%N = that%N
         if (allocated(that%SP)) then
           s_SP = size(that%SP)
           if (s_SP.gt.0) then
             allocate(this%SP(s_SP))
             do i_SP=1,s_SP
               call init(this%SP(i_SP),that%SP(i_SP))
             enddo
           endif
         endif
         this%defined = that%defined
       end subroutine

       subroutine delete_procedure_array_plane_op(this)
         implicit none
         type(procedure_array_plane_op),intent(inout) :: this
         integer :: i_SP
         integer :: s_SP
         this%N = 0
         if (allocated(this%SP)) then
           s_SP = size(this%SP)
           do i_SP=1,s_SP
             call delete(this%SP(i_SP))
           enddo
           deallocate(this%SP)
         endif
         this%defined = .false.
       end subroutine

       subroutine display_procedure_array_plane_op(this,un)
         implicit none
         type(procedure_array_plane_op),intent(in) :: this
         integer,intent(in) :: un
         integer :: i_SP
         integer :: s_SP
         write(un,*) ' -------------------- procedure_array_plane_op'
         write(un,*) 'N       = ',this%N
         if (allocated(this%SP)) then
           s_SP = size(this%SP)
           do i_SP=1,s_SP
             call display(this%SP(i_SP),un)
           enddo
         endif
         write(un,*) 'defined = ',this%defined
       end subroutine

       subroutine display_short_procedure_array_plane_op(this,un)
         implicit none
         type(procedure_array_plane_op),intent(in) :: this
         integer,intent(in) :: un
         integer :: i_SP
         integer :: s_SP
         write(un,*) 'N       = ',this%N
         if (allocated(this%SP)) then
           s_SP = size(this%SP)
           do i_SP=1,s_SP
             call display(this%SP(i_SP),un)
           enddo
         endif
         write(un,*) 'defined = ',this%defined
       end subroutine

       subroutine print_procedure_array_plane_op(this)
         implicit none
         type(procedure_array_plane_op),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_procedure_array_plane_op(this)
         implicit none
         type(procedure_array_plane_op),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_procedure_array_plane_op(this,un)
         implicit none
         type(procedure_array_plane_op),intent(in) :: this
         integer,intent(in) :: un
         integer :: i_SP
         integer :: s_SP
         write(un,*) 'N        = ';write(un,*) this%N
         if (allocated(this%SP)) then
           s_SP = size(this%SP)
           write(un,*) s_SP
           do i_SP=1,s_SP
             call export(this%SP(i_SP),un)
           enddo
         endif
         write(un,*) 'defined  = ';write(un,*) this%defined
       end subroutine

       subroutine import_procedure_array_plane_op(this,un)
         implicit none
         type(procedure_array_plane_op),intent(inout) :: this
         integer,intent(in) :: un
         integer :: i_SP
         integer :: s_SP
         call delete(this)
         read(un,*); read(un,*) this%N
         if (allocated(this%SP)) then
           read(un,*) s_SP
           do i_SP=1,s_SP
             call import(this%SP(i_SP),un)
           enddo
         endif
         read(un,*); read(un,*) this%defined
       end subroutine

       subroutine display_wrapper_procedure_array_plane_op(this,dir,name)
         implicit none
         type(procedure_array_plane_op),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine export_wrapper_procedure_array_plane_op(this,dir,name)
         implicit none
         type(procedure_array_plane_op),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrapper_procedure_array_plane_op(this,dir,name)
         implicit none
         type(procedure_array_plane_op),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call import(this,un)
         close(un)
       end subroutine

       end module