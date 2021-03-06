       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module time_statistics_params_mod
       use datatype_conversion_mod
       use IO_tools_mod
       use stats_period_mod
       use string_mod
       use dir_manip_mod
       implicit none

       private
       public :: time_statistics_params
       public :: init,delete,display,display_short,display,print,print_short,&
       export,export_primitives,import,export_folder_structure,&
       export_structured,import_structured,import_primitives,export,import,&
       set_IO_dir,make_IO_dir,suppress_warnings

       interface init;                   module procedure init_copy_time_statistics_params;              end interface
       interface delete;                 module procedure delete_time_statistics_params;                 end interface
       interface display;                module procedure display_time_statistics_params;                end interface
       interface display_short;          module procedure display_short_time_statistics_params;          end interface
       interface display;                module procedure display_wrap_time_statistics_params;           end interface
       interface print;                  module procedure print_time_statistics_params;                  end interface
       interface print_short;            module procedure print_short_time_statistics_params;            end interface
       interface export;                 module procedure export_time_statistics_params;                 end interface
       interface export_primitives;      module procedure export_primitives_time_statistics_params;      end interface
       interface import;                 module procedure import_time_statistics_params;                 end interface
       interface export_folder_structure;module procedure export_folder_structure_time_statistics_params;end interface
       interface export_structured;      module procedure export_structured_D_time_statistics_params;    end interface
       interface import_structured;      module procedure import_structured_D_time_statistics_params;    end interface
       interface import_primitives;      module procedure import_primitives_time_statistics_params;      end interface
       interface export;                 module procedure export_wrap_time_statistics_params;            end interface
       interface import;                 module procedure import_wrap_time_statistics_params;            end interface
       interface set_IO_dir;             module procedure set_IO_dir_time_statistics_params;             end interface
       interface make_IO_dir;            module procedure make_IO_dir_time_statistics_params;            end interface
       interface suppress_warnings;      module procedure suppress_warnings_time_statistics_params;      end interface

       type time_statistics_params
         logical :: collect = .false.
         type(stats_period) :: O1_stats
         type(stats_period) :: O2_stats
       end type

       contains

       subroutine init_copy_time_statistics_params(this,that)
         implicit none
         type(time_statistics_params),intent(inout) :: this
         type(time_statistics_params),intent(in) :: that
         call delete(this)
         this%collect = that%collect
         call init(this%O1_stats,that%O1_stats)
         call init(this%O2_stats,that%O2_stats)
       end subroutine

       subroutine delete_time_statistics_params(this)
         implicit none
         type(time_statistics_params),intent(inout) :: this
         this%collect = .false.
         call delete(this%O1_stats)
         call delete(this%O2_stats)
       end subroutine

       subroutine display_time_statistics_params(this,un)
         implicit none
         type(time_statistics_params),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'collect  = ',this%collect
         call display(this%O1_stats,un)
         call display(this%O2_stats,un)
       end subroutine

       subroutine display_short_time_statistics_params(this,un)
         implicit none
         type(time_statistics_params),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'collect  = ',this%collect
         call display(this%O1_stats,un)
         call display(this%O2_stats,un)
       end subroutine

       subroutine display_wrap_time_statistics_params(this,dir,name)
         implicit none
         type(time_statistics_params),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine print_time_statistics_params(this)
         implicit none
         type(time_statistics_params),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_time_statistics_params(this)
         implicit none
         type(time_statistics_params),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_time_statistics_params(this,un)
         implicit none
         type(time_statistics_params),intent(in) :: this
         integer,intent(in) :: un
         call export_primitives(this,un)
         call export(this%O1_stats,un)
         call export(this%O2_stats,un)
       end subroutine

       subroutine import_time_statistics_params(this,un)
         implicit none
         type(time_statistics_params),intent(inout) :: this
         integer,intent(in) :: un
         call delete(this)
         call import_primitives(this,un)
         call import(this%O1_stats,un)
         call import(this%O2_stats,un)
       end subroutine

       subroutine export_primitives_time_statistics_params(this,un)
         implicit none
         type(time_statistics_params),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'collect   = ';write(un,*) this%collect
       end subroutine

       subroutine import_primitives_time_statistics_params(this,un)
         implicit none
         type(time_statistics_params),intent(inout) :: this
         integer,intent(in) :: un
         read(un,*); read(un,*) this%collect
       end subroutine

       subroutine export_wrap_time_statistics_params(this,dir,name)
         implicit none
         type(time_statistics_params),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrap_time_statistics_params(this,dir,name)
         implicit none
         type(time_statistics_params),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine set_IO_dir_time_statistics_params(this,dir)
         implicit none
         type(time_statistics_params),intent(inout) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         call set_IO_dir(this%O1_stats,dir//'O1_stats'//fortran_PS)
         call set_IO_dir(this%O2_stats,dir//'O2_stats'//fortran_PS)
       end subroutine

       subroutine make_IO_dir_time_statistics_params(this,dir)
         implicit none
         type(time_statistics_params),intent(inout) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         call make_dir_quiet(dir)
         call make_IO_dir(this%O1_stats,dir//'O1_stats'//fortran_PS)
         call make_IO_dir(this%O2_stats,dir//'O2_stats'//fortran_PS)
       end subroutine

       subroutine export_folder_structure_time_statistics_params(this,dir)
         implicit none
         type(time_statistics_params),intent(in) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         call export_structured(this%O1_stats,dir//'O1_stats'//fortran_PS)
         call export_structured(this%O2_stats,dir//'O2_stats'//fortran_PS)
       end subroutine

       subroutine export_structured_D_time_statistics_params(this,dir)
         implicit none
         type(time_statistics_params),intent(in) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = new_and_open(dir,'primitives')
         call export_primitives(this,un)
         call export_structured(this%O1_stats,dir//'O1_stats'//fortran_PS)
         call export_structured(this%O2_stats,dir//'O2_stats'//fortran_PS)
         close(un)
       end subroutine

       subroutine import_structured_D_time_statistics_params(this,dir)
         implicit none
         type(time_statistics_params),intent(inout) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = open_to_read(dir,'primitives')
         call import_primitives(this,un)
         call import_structured(this%O1_stats,dir//'O1_stats'//fortran_PS)
         call import_structured(this%O2_stats,dir//'O2_stats'//fortran_PS)
         close(un)
       end subroutine

       subroutine suppress_warnings_time_statistics_params(this)
         implicit none
         type(time_statistics_params),intent(in) :: this
         if (.false.) then
           call print(this)
         endif
       end subroutine

       end module