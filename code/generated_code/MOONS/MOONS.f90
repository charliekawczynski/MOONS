       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module MOONS_mod
       use IO_tools_mod
       use config_mod
       use datatype_conversion_mod
       use dir_manip_mod
       use governing_equations_mod
       use mesh_mod
       use string_mod
       implicit none

       private
       public :: MOONS
       public :: init,delete,display,print,export,import
       public :: display_short,print_short

       public :: export_primitives,import_primitives

       public :: export_restart,import_restart

       public :: make_restart_dir

       public :: suppress_warnings

       interface init;             module procedure init_copy_MOONS;        end interface
       interface delete;           module procedure delete_MOONS;           end interface
       interface display;          module procedure display_MOONS;          end interface
       interface display_short;    module procedure display_short_MOONS;    end interface
       interface display;          module procedure display_wrap_MOONS;     end interface
       interface print;            module procedure print_MOONS;            end interface
       interface print_short;      module procedure print_short_MOONS;      end interface
       interface export;           module procedure export_MOONS;           end interface
       interface export_primitives;module procedure export_primitives_MOONS;end interface
       interface export_restart;   module procedure export_restart_MOONS;   end interface
       interface import;           module procedure import_MOONS;           end interface
       interface import_restart;   module procedure import_restart_MOONS;   end interface
       interface import_primitives;module procedure import_primitives_MOONS;end interface
       interface export;           module procedure export_wrap_MOONS;      end interface
       interface import;           module procedure import_wrap_MOONS;      end interface
       interface make_restart_dir; module procedure make_restart_dir_MOONS; end interface
       interface suppress_warnings;module procedure suppress_warnings_MOONS;end interface

       type MOONS
         type(config) :: C
         type(governing_equations) :: GE
         type(mesh) :: m_temp
       end type

       contains

       subroutine init_copy_MOONS(this,that)
         implicit none
         type(MOONS),intent(inout) :: this
         type(MOONS),intent(in) :: that
         call delete(this)
         call init(this%C,that%C)
         call init(this%GE,that%GE)
         call init(this%m_temp,that%m_temp)
       end subroutine

       subroutine delete_MOONS(this)
         implicit none
         type(MOONS),intent(inout) :: this
         call delete(this%C)
         call delete(this%GE)
         call delete(this%m_temp)
       end subroutine

       subroutine display_MOONS(this,un)
         implicit none
         type(MOONS),intent(in) :: this
         integer,intent(in) :: un
         call display(this%C,un)
         call display(this%GE,un)
         call display(this%m_temp,un)
       end subroutine

       subroutine display_short_MOONS(this,un)
         implicit none
         type(MOONS),intent(in) :: this
         integer,intent(in) :: un
         call display(this%C,un)
         call display(this%GE,un)
         call display(this%m_temp,un)
       end subroutine

       subroutine display_wrap_MOONS(this,dir,name)
         implicit none
         type(MOONS),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine print_MOONS(this)
         implicit none
         type(MOONS),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_MOONS(this)
         implicit none
         type(MOONS),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_primitives_MOONS(this,un)
         implicit none
         type(MOONS),intent(in) :: this
         integer,intent(in) :: un
         integer :: un_suppress_warning
         un_suppress_warning = un
         call suppress_warnings(this)
       end subroutine

       subroutine export_MOONS(this,un)
         implicit none
         type(MOONS),intent(in) :: this
         integer,intent(in) :: un
         call export(this%C,un)
         call export(this%GE,un)
         call export(this%m_temp,un)
       end subroutine

       subroutine import_primitives_MOONS(this,un)
         implicit none
         type(MOONS),intent(inout) :: this
         integer,intent(in) :: un
         integer :: un_suppress_warning
         un_suppress_warning = un
         call suppress_warnings(this)
       end subroutine

       subroutine import_MOONS(this,un)
         implicit none
         type(MOONS),intent(inout) :: this
         integer,intent(in) :: un
         call delete(this)
         call import(this%C,un)
         call import(this%GE,un)
         call import(this%m_temp,un)
       end subroutine

       subroutine export_wrap_MOONS(this,dir,name)
         implicit none
         type(MOONS),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrap_MOONS(this,dir,name)
         implicit none
         type(MOONS),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call import(this,un)
         close(un)
       end subroutine

       subroutine make_restart_dir_MOONS(this,dir)
         implicit none
         type(MOONS),intent(in) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         call make_dir_quiet(dir)
         call make_restart_dir(this%C,dir//'C'//fortran_PS)
         call make_restart_dir(this%GE,dir//'GE'//fortran_PS)
         call make_restart_dir(this%m_temp,dir//'m_temp'//fortran_PS)
       end subroutine

       subroutine export_restart_MOONS(this,dir)
         implicit none
         type(MOONS),intent(in) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = new_and_open(dir,'primitives')
         call export_primitives(this,un)
         close(un)
         call export_restart(this%C,dir//'C'//fortran_PS)
         call export_restart(this%GE,dir//'GE'//fortran_PS)
         call export_restart(this%m_temp,dir//'m_temp'//fortran_PS)
       end subroutine

       subroutine import_restart_MOONS(this,dir)
         implicit none
         type(MOONS),intent(inout) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = open_to_read(dir,'primitives')
         call import_primitives(this,un)
         close(un)
         call import_restart(this%C,dir//'C'//fortran_PS)
         call import_restart(this%GE,dir//'GE'//fortran_PS)
         call import_restart(this%m_temp,dir//'m_temp'//fortran_PS)
       end subroutine

       subroutine suppress_warnings_MOONS(this)
         implicit none
         type(MOONS),intent(in) :: this
         if (.false.) call print(this)
       end subroutine

       end module