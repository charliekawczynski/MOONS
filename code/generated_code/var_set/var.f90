       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module var_mod
       use string_mod
       use solver_settings_mod
       use datatype_conversion_mod
       use IO_tools_mod
       use export_lines_mod
       use time_marching_params_mod
       use export_field_mod
       use matrix_free_params_mod
       use iter_solver_params_mod
       use export_planes_mod
       use dir_manip_mod
       implicit none

       private
       public :: var
       public :: init,delete,display,display_short,display,print,print_short,&
       export,export_primitives,import,export_folder_structure,&
       export_structured,import_structured,import_primitives,export,import,&
       set_IO_dir,make_IO_dir,suppress_warnings

       interface init;                   module procedure init_copy_var;              end interface
       interface delete;                 module procedure delete_var;                 end interface
       interface display;                module procedure display_var;                end interface
       interface display_short;          module procedure display_short_var;          end interface
       interface display;                module procedure display_wrap_var;           end interface
       interface print;                  module procedure print_var;                  end interface
       interface print_short;            module procedure print_short_var;            end interface
       interface export;                 module procedure export_var;                 end interface
       interface export_primitives;      module procedure export_primitives_var;      end interface
       interface import;                 module procedure import_var;                 end interface
       interface export_folder_structure;module procedure export_folder_structure_var;end interface
       interface export_structured;      module procedure export_structured_D_var;    end interface
       interface import_structured;      module procedure import_structured_D_var;    end interface
       interface import_primitives;      module procedure import_primitives_var;      end interface
       interface export;                 module procedure export_wrap_var;            end interface
       interface import;                 module procedure import_wrap_var;            end interface
       interface set_IO_dir;             module procedure set_IO_dir_var;             end interface
       interface make_IO_dir;            module procedure make_IO_dir_var;            end interface
       interface suppress_warnings;      module procedure suppress_warnings_var;      end interface

       type var
         integer :: IC = 0
         integer :: BC = 0
         type(solver_settings) :: SS
         type(matrix_free_params) :: MFP
         type(time_marching_params) :: TMP
         type(iter_solver_params) :: ISP
         type(export_lines) :: unsteady_lines
         type(export_planes) :: unsteady_planes
         type(export_field) :: unsteady_field
       end type

       contains

       subroutine init_copy_var(this,that)
         implicit none
         type(var),intent(inout) :: this
         type(var),intent(in) :: that
         call delete(this)
         this%IC = that%IC
         this%BC = that%BC
         call init(this%SS,that%SS)
         call init(this%MFP,that%MFP)
         call init(this%TMP,that%TMP)
         call init(this%ISP,that%ISP)
         call init(this%unsteady_lines,that%unsteady_lines)
         call init(this%unsteady_planes,that%unsteady_planes)
         call init(this%unsteady_field,that%unsteady_field)
       end subroutine

       subroutine delete_var(this)
         implicit none
         type(var),intent(inout) :: this
         this%IC = 0
         this%BC = 0
         call delete(this%SS)
         call delete(this%MFP)
         call delete(this%TMP)
         call delete(this%ISP)
         call delete(this%unsteady_lines)
         call delete(this%unsteady_planes)
         call delete(this%unsteady_field)
       end subroutine

       subroutine display_var(this,un)
         implicit none
         type(var),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'IC              = ',this%IC
         write(un,*) 'BC              = ',this%BC
         call display(this%SS,un)
         call display(this%MFP,un)
         call display(this%TMP,un)
         call display(this%ISP,un)
         call display(this%unsteady_lines,un)
         call display(this%unsteady_planes,un)
         call display(this%unsteady_field,un)
       end subroutine

       subroutine display_short_var(this,un)
         implicit none
         type(var),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'IC              = ',this%IC
         write(un,*) 'BC              = ',this%BC
         call display(this%SS,un)
         call display(this%MFP,un)
         call display(this%TMP,un)
         call display(this%ISP,un)
         call display(this%unsteady_lines,un)
         call display(this%unsteady_planes,un)
         call display(this%unsteady_field,un)
       end subroutine

       subroutine display_wrap_var(this,dir,name)
         implicit none
         type(var),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine print_var(this)
         implicit none
         type(var),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_var(this)
         implicit none
         type(var),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_var(this,un)
         implicit none
         type(var),intent(in) :: this
         integer,intent(in) :: un
         call export_primitives(this,un)
         call export(this%SS,un)
         call export(this%MFP,un)
         call export(this%TMP,un)
         call export(this%ISP,un)
         call export(this%unsteady_lines,un)
         call export(this%unsteady_planes,un)
         call export(this%unsteady_field,un)
       end subroutine

       subroutine import_var(this,un)
         implicit none
         type(var),intent(inout) :: this
         integer,intent(in) :: un
         call delete(this)
         call import_primitives(this,un)
         call import(this%SS,un)
         call import(this%MFP,un)
         call import(this%TMP,un)
         call import(this%ISP,un)
         call import(this%unsteady_lines,un)
         call import(this%unsteady_planes,un)
         call import(this%unsteady_field,un)
       end subroutine

       subroutine export_primitives_var(this,un)
         implicit none
         type(var),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'IC               = ';write(un,*) this%IC
         write(un,*) 'BC               = ';write(un,*) this%BC
       end subroutine

       subroutine import_primitives_var(this,un)
         implicit none
         type(var),intent(inout) :: this
         integer,intent(in) :: un
         read(un,*); read(un,*) this%IC
         read(un,*); read(un,*) this%BC
       end subroutine

       subroutine export_wrap_var(this,dir,name)
         implicit none
         type(var),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrap_var(this,dir,name)
         implicit none
         type(var),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine set_IO_dir_var(this,dir)
         implicit none
         type(var),intent(inout) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         call set_IO_dir(this%SS,dir//'SS'//fortran_PS)
         call set_IO_dir(this%MFP,dir//'MFP'//fortran_PS)
         call set_IO_dir(this%TMP,dir//'TMP'//fortran_PS)
         call set_IO_dir(this%ISP,dir//'ISP'//fortran_PS)
         call set_IO_dir(this%unsteady_lines,&
         dir//'unsteady_lines'//fortran_PS)
         call set_IO_dir(this%unsteady_planes,&
         dir//'unsteady_planes'//fortran_PS)
         call set_IO_dir(this%unsteady_field,&
         dir//'unsteady_field'//fortran_PS)
       end subroutine

       subroutine make_IO_dir_var(this,dir)
         implicit none
         type(var),intent(inout) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         call make_dir_quiet(dir)
         call make_IO_dir(this%SS,dir//'SS'//fortran_PS)
         call make_IO_dir(this%MFP,dir//'MFP'//fortran_PS)
         call make_IO_dir(this%TMP,dir//'TMP'//fortran_PS)
         call make_IO_dir(this%ISP,dir//'ISP'//fortran_PS)
         call make_IO_dir(this%unsteady_lines,&
         dir//'unsteady_lines'//fortran_PS)
         call make_IO_dir(this%unsteady_planes,&
         dir//'unsteady_planes'//fortran_PS)
         call make_IO_dir(this%unsteady_field,&
         dir//'unsteady_field'//fortran_PS)
       end subroutine

       subroutine export_folder_structure_var(this,dir)
         implicit none
         type(var),intent(in) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         call export_structured(this%SS,dir//'SS'//fortran_PS)
         call export_structured(this%MFP,dir//'MFP'//fortran_PS)
         call export_structured(this%TMP,dir//'TMP'//fortran_PS)
         call export_structured(this%ISP,dir//'ISP'//fortran_PS)
         call export_structured(this%unsteady_lines,&
         dir//'unsteady_lines'//fortran_PS)
         call export_structured(this%unsteady_planes,&
         dir//'unsteady_planes'//fortran_PS)
         call export_structured(this%unsteady_field,&
         dir//'unsteady_field'//fortran_PS)
       end subroutine

       subroutine export_structured_D_var(this,dir)
         implicit none
         type(var),intent(in) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = new_and_open(dir,'primitives')
         call export_primitives(this,un)
         call export_structured(this%SS,dir//'SS'//fortran_PS)
         call export_structured(this%MFP,dir//'MFP'//fortran_PS)
         call export_structured(this%TMP,dir//'TMP'//fortran_PS)
         call export_structured(this%ISP,dir//'ISP'//fortran_PS)
         call export_structured(this%unsteady_lines,&
         dir//'unsteady_lines'//fortran_PS)
         call export_structured(this%unsteady_planes,&
         dir//'unsteady_planes'//fortran_PS)
         call export_structured(this%unsteady_field,&
         dir//'unsteady_field'//fortran_PS)
         close(un)
       end subroutine

       subroutine import_structured_D_var(this,dir)
         implicit none
         type(var),intent(inout) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = open_to_read(dir,'primitives')
         call import_primitives(this,un)
         call import_structured(this%SS,dir//'SS'//fortran_PS)
         call import_structured(this%MFP,dir//'MFP'//fortran_PS)
         call import_structured(this%TMP,dir//'TMP'//fortran_PS)
         call import_structured(this%ISP,dir//'ISP'//fortran_PS)
         call import_structured(this%unsteady_lines,&
         dir//'unsteady_lines'//fortran_PS)
         call import_structured(this%unsteady_planes,&
         dir//'unsteady_planes'//fortran_PS)
         call import_structured(this%unsteady_field,&
         dir//'unsteady_field'//fortran_PS)
         close(un)
       end subroutine

       subroutine suppress_warnings_var(this)
         implicit none
         type(var),intent(in) :: this
         if (.false.) then
           call print(this)
         endif
       end subroutine

       end module