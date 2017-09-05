       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module RK_params_mod
       use IO_tools_mod
       use array_mod
       implicit none

       private
       public :: RK_params
       public :: init,delete,display,print,export,import
       public :: display_short,print_short

       interface init;         module procedure init_copy_RK;    end interface
       interface delete;       module procedure delete_RK;       end interface
       interface display;      module procedure display_RK;      end interface
       interface display_short;module procedure display_short_RK;end interface
       interface display;      module procedure display_wrap_RK; end interface
       interface print;        module procedure print_RK;        end interface
       interface print_short;  module procedure print_short_RK;  end interface
       interface export;       module procedure export_RK;       end interface
       interface import;       module procedure import_RK;       end interface
       interface export;       module procedure export_wrap_RK;  end interface
       interface import;       module procedure import_wrap_RK;  end interface

       type RK_params
         integer :: n_stages = 0
         integer :: n = 0
         logical :: RK_active = .false.
         type(array) :: gamma
         type(array) :: zeta
         type(array) :: alpha
         type(array) :: beta
       end type

       contains

       subroutine init_copy_RK(this,that)
         implicit none
         type(RK_params),intent(inout) :: this
         type(RK_params),intent(in) :: that
         call delete(this)
         this%n_stages = that%n_stages
         this%n = that%n
         this%RK_active = that%RK_active
         call init(this%gamma,that%gamma)
         call init(this%zeta,that%zeta)
         call init(this%alpha,that%alpha)
         call init(this%beta,that%beta)
       end subroutine

       subroutine delete_RK(this)
         implicit none
         type(RK_params),intent(inout) :: this
         this%n_stages = 0
         this%n = 0
         this%RK_active = .false.
         call delete(this%gamma)
         call delete(this%zeta)
         call delete(this%alpha)
         call delete(this%beta)
       end subroutine

       subroutine display_RK(this,un)
         implicit none
         type(RK_params),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) ' -------------------- RK_params'
         write(un,*) 'n_stages  = ',this%n_stages
         write(un,*) 'n         = ',this%n
         write(un,*) 'RK_active = ',this%RK_active
         call display(this%gamma,un)
         call display(this%zeta,un)
         call display(this%alpha,un)
         call display(this%beta,un)
       end subroutine

       subroutine display_short_RK(this,un)
         implicit none
         type(RK_params),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'n_stages  = ',this%n_stages
         write(un,*) 'n         = ',this%n
         write(un,*) 'RK_active = ',this%RK_active
         call display(this%gamma,un)
         call display(this%zeta,un)
         call display(this%alpha,un)
         call display(this%beta,un)
       end subroutine

       subroutine print_RK(this)
         implicit none
         type(RK_params),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_RK(this)
         implicit none
         type(RK_params),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_RK(this,un)
         implicit none
         type(RK_params),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'n_stages   = ';write(un,*) this%n_stages
         write(un,*) 'n          = ';write(un,*) this%n
         write(un,*) 'RK_active  = ';write(un,*) this%RK_active
         call export(this%gamma,un)
         call export(this%zeta,un)
         call export(this%alpha,un)
         call export(this%beta,un)
       end subroutine

       subroutine import_RK(this,un)
         implicit none
         type(RK_params),intent(inout) :: this
         integer,intent(in) :: un
         call delete(this)
         read(un,*); read(un,*) this%n_stages
         read(un,*); read(un,*) this%n
         read(un,*); read(un,*) this%RK_active
         call import(this%gamma,un)
         call import(this%zeta,un)
         call import(this%alpha,un)
         call import(this%beta,un)
       end subroutine

       subroutine display_wrap_RK(this,dir,name)
         implicit none
         type(RK_params),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine export_wrap_RK(this,dir,name)
         implicit none
         type(RK_params),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrap_RK(this,dir,name)
         implicit none
         type(RK_params),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call import(this,un)
         close(un)
       end subroutine

       end module