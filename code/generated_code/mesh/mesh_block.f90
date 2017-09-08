       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module mesh_block_mod
       use IO_tools_mod
       use block_mod
       use mesh_mod
       implicit none

       private
       public :: mesh_block
       public :: init,delete,display,print,export,import
       public :: display_short,print_short

       interface init;         module procedure init_copy_mesh_block;    end interface
       interface delete;       module procedure delete_mesh_block;       end interface
       interface display;      module procedure display_mesh_block;      end interface
       interface display_short;module procedure display_short_mesh_block;end interface
       interface display;      module procedure display_wrap_mesh_block; end interface
       interface print;        module procedure print_mesh_block;        end interface
       interface print_short;  module procedure print_short_mesh_block;  end interface
       interface export;       module procedure export_mesh_block;       end interface
       interface import;       module procedure import_mesh_block;       end interface
       interface export;       module procedure export_wrap_mesh_block;  end interface
       interface import;       module procedure import_wrap_mesh_block;  end interface

       type mesh_block
         type(mesh) :: m
         type(block) :: B
       end type

       contains

       subroutine init_copy_mesh_block(this,that)
         implicit none
         type(mesh_block),intent(inout) :: this
         type(mesh_block),intent(in) :: that
         call delete(this)
         call init(this%m,that%m)
         call init(this%B,that%B)
       end subroutine

       subroutine delete_mesh_block(this)
         implicit none
         type(mesh_block),intent(inout) :: this
         call delete(this%m)
         call delete(this%B)
       end subroutine

       subroutine display_mesh_block(this,un)
         implicit none
         type(mesh_block),intent(in) :: this
         integer,intent(in) :: un
         call display(this%m,un)
         call display(this%B,un)
       end subroutine

       subroutine display_short_mesh_block(this,un)
         implicit none
         type(mesh_block),intent(in) :: this
         integer,intent(in) :: un
         call display(this%m,un)
         call display(this%B,un)
       end subroutine

       subroutine print_mesh_block(this)
         implicit none
         type(mesh_block),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_mesh_block(this)
         implicit none
         type(mesh_block),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_mesh_block(this,un)
         implicit none
         type(mesh_block),intent(in) :: this
         integer,intent(in) :: un
         call export(this%m,un)
         call export(this%B,un)
       end subroutine

       subroutine import_mesh_block(this,un)
         implicit none
         type(mesh_block),intent(inout) :: this
         integer,intent(in) :: un
         call delete(this)
         call import(this%m,un)
         call import(this%B,un)
       end subroutine

       subroutine display_wrap_mesh_block(this,dir,name)
         implicit none
         type(mesh_block),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine export_wrap_mesh_block(this,dir,name)
         implicit none
         type(mesh_block),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrap_mesh_block(this,dir,name)
         implicit none
         type(mesh_block),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call import(this,un)
         close(un)
       end subroutine

       end module