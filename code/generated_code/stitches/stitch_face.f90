       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module stitch_face_mod
       use string_mod
       use datatype_conversion_mod
       use IO_tools_mod
       use dir_manip_mod
       implicit none

       private
       public :: stitch_face
       public :: init,delete,display,display_short,display,print,print_short,&
       export,export_primitives,import,export_folder_structure,&
       export_structured,import_structured,import_primitives,export,import,&
       set_IO_dir,make_IO_dir,suppress_warnings

       interface init;                   module procedure init_copy_stitch_face;              end interface
       interface delete;                 module procedure delete_stitch_face;                 end interface
       interface display;                module procedure display_stitch_face;                end interface
       interface display_short;          module procedure display_short_stitch_face;          end interface
       interface display;                module procedure display_wrap_stitch_face;           end interface
       interface print;                  module procedure print_stitch_face;                  end interface
       interface print_short;            module procedure print_short_stitch_face;            end interface
       interface export;                 module procedure export_stitch_face;                 end interface
       interface export_primitives;      module procedure export_primitives_stitch_face;      end interface
       interface import;                 module procedure import_stitch_face;                 end interface
       interface export_folder_structure;module procedure export_folder_structure_stitch_face;end interface
       interface export_structured;      module procedure export_structured_D_stitch_face;    end interface
       interface import_structured;      module procedure import_structured_D_stitch_face;    end interface
       interface import_primitives;      module procedure import_primitives_stitch_face;      end interface
       interface export;                 module procedure export_wrap_stitch_face;            end interface
       interface import;                 module procedure import_wrap_stitch_face;            end interface
       interface set_IO_dir;             module procedure set_IO_dir_stitch_face;             end interface
       interface make_IO_dir;            module procedure make_IO_dir_stitch_face;            end interface
       interface suppress_warnings;      module procedure suppress_warnings_stitch_face;      end interface

       type stitch_face
         logical,dimension(3) :: hmin = .false.
         logical,dimension(3) :: hmax = .false.
         integer,dimension(3) :: hmin_id = 0
         integer,dimension(3) :: hmax_id = 0
       end type

       contains

       subroutine init_copy_stitch_face(this,that)
         implicit none
         type(stitch_face),intent(inout) :: this
         type(stitch_face),intent(in) :: that
         call delete(this)
         this%hmin = that%hmin
         this%hmax = that%hmax
         this%hmin_id = that%hmin_id
         this%hmax_id = that%hmax_id
       end subroutine

       subroutine delete_stitch_face(this)
         implicit none
         type(stitch_face),intent(inout) :: this
         this%hmin = .false.
         this%hmax = .false.
         this%hmin_id = 0
         this%hmax_id = 0
       end subroutine

       subroutine display_stitch_face(this,un)
         implicit none
         type(stitch_face),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'hmin    = ',this%hmin
         write(un,*) 'hmax    = ',this%hmax
         write(un,*) 'hmin_id = ',this%hmin_id
         write(un,*) 'hmax_id = ',this%hmax_id
       end subroutine

       subroutine display_short_stitch_face(this,un)
         implicit none
         type(stitch_face),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'hmin    = ',this%hmin
         write(un,*) 'hmax    = ',this%hmax
         write(un,*) 'hmin_id = ',this%hmin_id
         write(un,*) 'hmax_id = ',this%hmax_id
       end subroutine

       subroutine display_wrap_stitch_face(this,dir,name)
         implicit none
         type(stitch_face),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine print_stitch_face(this)
         implicit none
         type(stitch_face),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_stitch_face(this)
         implicit none
         type(stitch_face),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_stitch_face(this,un)
         implicit none
         type(stitch_face),intent(in) :: this
         integer,intent(in) :: un
         call export_primitives(this,un)
       end subroutine

       subroutine import_stitch_face(this,un)
         implicit none
         type(stitch_face),intent(inout) :: this
         integer,intent(in) :: un
         call delete(this)
         call import_primitives(this,un)
       end subroutine

       subroutine export_primitives_stitch_face(this,un)
         implicit none
         type(stitch_face),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'hmin     = ';write(un,*) this%hmin
         write(un,*) 'hmax     = ';write(un,*) this%hmax
         write(un,*) 'hmin_id  = ';write(un,*) this%hmin_id
         write(un,*) 'hmax_id  = ';write(un,*) this%hmax_id
       end subroutine

       subroutine import_primitives_stitch_face(this,un)
         implicit none
         type(stitch_face),intent(inout) :: this
         integer,intent(in) :: un
         read(un,*); read(un,*) this%hmin
         read(un,*); read(un,*) this%hmax
         read(un,*); read(un,*) this%hmin_id
         read(un,*); read(un,*) this%hmax_id
       end subroutine

       subroutine export_wrap_stitch_face(this,dir,name)
         implicit none
         type(stitch_face),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrap_stitch_face(this,dir,name)
         implicit none
         type(stitch_face),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine set_IO_dir_stitch_face(this,dir)
         implicit none
         type(stitch_face),intent(inout) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         if (.false.) then
           write(*,*) dir
         endif
       end subroutine

       subroutine make_IO_dir_stitch_face(this,dir)
         implicit none
         type(stitch_face),intent(inout) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         call make_dir_quiet(dir)
       end subroutine

       subroutine export_folder_structure_stitch_face(this,dir)
         implicit none
         type(stitch_face),intent(in) :: this
         character(len=*),intent(in) :: dir
         integer :: un
       end subroutine

       subroutine export_structured_D_stitch_face(this,dir)
         implicit none
         type(stitch_face),intent(in) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = new_and_open(dir,'primitives')
         call export_primitives(this,un)
         close(un)
       end subroutine

       subroutine import_structured_D_stitch_face(this,dir)
         implicit none
         type(stitch_face),intent(inout) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = open_to_read(dir,'primitives')
         call import_primitives(this,un)
         close(un)
       end subroutine

       subroutine suppress_warnings_stitch_face(this)
         implicit none
         type(stitch_face),intent(in) :: this
         if (.false.) then
           call print(this)
         endif
       end subroutine

       end module