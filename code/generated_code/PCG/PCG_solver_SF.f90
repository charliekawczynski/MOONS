       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module PCG_solver_SF_mod
       use IO_tools_mod
       use matrix_free_operators_interfaces_mod
       use preconditioner_interfaces_mod
       use SF_mod
       use TF_mod
       use datatype_conversion_mod
       use dir_manip_mod
       use iter_solver_params_mod
       use matrix_free_params_mod
       use norms_mod
       use string_mod
       implicit none

       private
       public :: PCG_solver_SF
       public :: init,delete,display,print,export,import
       public :: display_short,print_short

       public :: export_primitives,import_primitives

       public :: export_structured,import_structured

       public :: set_IO_dir,make_IO_dir

       public :: suppress_warnings

       interface init;             module procedure init_copy_PCG_solver_SF;           end interface
       interface delete;           module procedure delete_PCG_solver_SF;              end interface
       interface display;          module procedure display_PCG_solver_SF;             end interface
       interface display_short;    module procedure display_short_PCG_solver_SF;       end interface
       interface display;          module procedure display_wrap_PCG_solver_SF;        end interface
       interface print;            module procedure print_PCG_solver_SF;               end interface
       interface print_short;      module procedure print_short_PCG_solver_SF;         end interface
       interface export;           module procedure export_PCG_solver_SF;              end interface
       interface export_primitives;module procedure export_primitives_PCG_solver_SF;   end interface
       interface import;           module procedure import_PCG_solver_SF;              end interface
       interface export_structured;module procedure export_structured_D_PCG_solver_SF; end interface
       interface import_structured;module procedure import_structured_D_PCG_solver_SF; end interface
       interface import_primitives;module procedure import_primitives_PCG_solver_SF;   end interface
       interface export;           module procedure export_wrap_PCG_solver_SF;         end interface
       interface import;           module procedure import_wrap_PCG_solver_SF;         end interface
       interface set_IO_dir;       module procedure set_IO_dir_PCG_solver_SF;          end interface
       interface make_IO_dir;      module procedure make_IO_dir_PCG_solver_SF;         end interface
       interface suppress_warnings;module procedure suppress_warnings_PCG_solver_SF;   end interface
       interface export;           module procedure export_DN_PCG_solver_SF;           end interface
       interface import;           module procedure import_DN_PCG_solver_SF;           end interface
       interface export_structured;module procedure export_structured_DN_PCG_solver_SF;end interface
       interface import_structured;module procedure import_structured_DN_PCG_solver_SF;end interface

       type PCG_solver_SF
         integer :: un = 0
         integer :: un_convergence = 0
         type(matrix_free_params) :: MFP
         type(TF) :: tempk
         type(TF) :: k
         type(SF) :: r
         type(SF) :: p
         type(SF) :: tempx
         type(SF) :: Ax
         type(SF) :: x_BC
         type(SF) :: vol
         type(SF) :: z
         type(SF) :: Minv
         type(norms) :: norm
         type(iter_solver_params) :: ISP
         type(string) :: dir
         type(string) :: name
         procedure(preconditioner_SF),pointer,nopass :: prec
         procedure(op_SF),pointer,nopass :: operator
         procedure(op_SF_explicit),pointer,nopass :: operator_explicit
       end type

       contains

       subroutine init_copy_PCG_solver_SF(this,that)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         type(PCG_solver_SF),intent(in) :: that
         call delete(this)
         this%un = that%un
         this%un_convergence = that%un_convergence
         call init(this%MFP,that%MFP)
         call init(this%tempk,that%tempk)
         call init(this%k,that%k)
         call init(this%r,that%r)
         call init(this%p,that%p)
         call init(this%tempx,that%tempx)
         call init(this%Ax,that%Ax)
         call init(this%x_BC,that%x_BC)
         call init(this%vol,that%vol)
         call init(this%z,that%z)
         call init(this%Minv,that%Minv)
         call init(this%norm,that%norm)
         call init(this%ISP,that%ISP)
         call init(this%dir,that%dir)
         call init(this%name,that%name)
         this%prec => that%prec
         this%operator => that%operator
         this%operator_explicit => that%operator_explicit
       end subroutine

       subroutine delete_PCG_solver_SF(this)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         this%un = 0
         this%un_convergence = 0
         call delete(this%MFP)
         call delete(this%tempk)
         call delete(this%k)
         call delete(this%r)
         call delete(this%p)
         call delete(this%tempx)
         call delete(this%Ax)
         call delete(this%x_BC)
         call delete(this%vol)
         call delete(this%z)
         call delete(this%Minv)
         call delete(this%norm)
         call delete(this%ISP)
         call delete(this%dir)
         call delete(this%name)
         nullify(this%prec)
         nullify(this%operator)
         nullify(this%operator_explicit)
       end subroutine

       subroutine display_PCG_solver_SF(this,un)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'un                = ',this%un
         write(un,*) 'un_convergence    = ',this%un_convergence
         call display(this%MFP,un)
         call display(this%tempk,un)
         call display(this%k,un)
         call display(this%r,un)
         call display(this%p,un)
         call display(this%tempx,un)
         call display(this%Ax,un)
         call display(this%x_BC,un)
         call display(this%vol,un)
         call display(this%z,un)
         call display(this%Minv,un)
         call display(this%norm,un)
         call display(this%ISP,un)
         call display(this%dir,un)
         call display(this%name,un)
       end subroutine

       subroutine display_short_PCG_solver_SF(this,un)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'un                = ',this%un
         write(un,*) 'un_convergence    = ',this%un_convergence
         call display(this%MFP,un)
         call display(this%tempk,un)
         call display(this%k,un)
         call display(this%r,un)
         call display(this%p,un)
         call display(this%tempx,un)
         call display(this%Ax,un)
         call display(this%x_BC,un)
         call display(this%vol,un)
         call display(this%z,un)
         call display(this%Minv,un)
         call display(this%norm,un)
         call display(this%ISP,un)
         call display(this%dir,un)
         call display(this%name,un)
       end subroutine

       subroutine display_wrap_PCG_solver_SF(this,dir,name)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine print_PCG_solver_SF(this)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_PCG_solver_SF(this)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_PCG_solver_SF(this,un)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'un                 = ';write(un,*) this%un
         write(un,*) 'un_convergence     = ';write(un,*) this%un_convergence
         call export(this%MFP,un)
         call export(this%tempk,un)
         call export(this%k,un)
         call export(this%r,un)
         call export(this%p,un)
         call export(this%tempx,un)
         call export(this%Ax,un)
         call export(this%x_BC,un)
         call export(this%vol,un)
         call export(this%z,un)
         call export(this%Minv,un)
         call export(this%norm,un)
         call export(this%ISP,un)
         call export(this%dir,un)
         call export(this%name,un)
       end subroutine

       subroutine import_PCG_solver_SF(this,un)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         integer,intent(in) :: un
         call delete(this)
         read(un,*); read(un,*) this%un
         read(un,*); read(un,*) this%un_convergence
         call import(this%MFP,un)
         call import(this%tempk,un)
         call import(this%k,un)
         call import(this%r,un)
         call import(this%p,un)
         call import(this%tempx,un)
         call import(this%Ax,un)
         call import(this%x_BC,un)
         call import(this%vol,un)
         call import(this%z,un)
         call import(this%Minv,un)
         call import(this%norm,un)
         call import(this%ISP,un)
         call import(this%dir,un)
         call import(this%name,un)
       end subroutine

       subroutine export_primitives_PCG_solver_SF(this,un)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'un                 = ';write(un,*) this%un
         write(un,*) 'un_convergence     = ';write(un,*) this%un_convergence
       end subroutine

       subroutine import_primitives_PCG_solver_SF(this,un)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         integer,intent(in) :: un
         read(un,*); read(un,*) this%un
         read(un,*); read(un,*) this%un_convergence
       end subroutine

       subroutine export_wrap_PCG_solver_SF(this,dir,name)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrap_PCG_solver_SF(this,dir,name)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine export_DN_PCG_solver_SF(this)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         call export(this,str(this%dir),str(this%name))
       end subroutine

       subroutine import_DN_PCG_solver_SF(this)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         type(string) :: dir,name
         integer :: un
         call init(dir,this%dir)
         call init(name,this%name)
         un = open_to_read(str(dir),str(name))
         call import(this,un)
         call delete(dir)
         call delete(name)
         close(un)
       end subroutine

       subroutine export_structured_DN_PCG_solver_SF(this)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         integer :: un
         un = new_and_open(str(this%dir),'primitives')
         call export_primitives(this,un)
         close(un)
         call export_structured(this%MFP,str(this%dir)//'MFP'//fortran_PS)
         call export_structured(this%norm,str(this%dir)//'norm'//fortran_PS)
         call export_structured(this%ISP,str(this%dir)//'ISP'//fortran_PS)
         call export_structured(this%dir,str(this%dir)//'dir'//fortran_PS)
         call export_structured(this%name,str(this%dir)//'name'//fortran_PS)
       end subroutine

       subroutine import_structured_DN_PCG_solver_SF(this)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         integer :: un
         un = open_to_read(str(this%dir),'primitives')
         call import_primitives(this,un)
         close(un)
         call import_structured(this%MFP,str(this%dir)//'MFP'//fortran_PS)
         call import_structured(this%norm,str(this%dir)//'norm'//fortran_PS)
         call import_structured(this%ISP,str(this%dir)//'ISP'//fortran_PS)
         call import_structured(this%dir,str(this%dir)//'dir'//fortran_PS)
         call import_structured(this%name,str(this%dir)//'name'//fortran_PS)
       end subroutine

       subroutine set_IO_dir_PCG_solver_SF(this,dir)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         call init(this%dir,dir)
         call init(this%name,'primitives')
         call set_IO_dir(this%MFP,dir//'MFP'//fortran_PS)
         call set_IO_dir(this%norm,dir//'norm'//fortran_PS)
         call set_IO_dir(this%ISP,dir//'ISP'//fortran_PS)
         call set_IO_dir(this%dir,dir//'dir'//fortran_PS)
         call set_IO_dir(this%name,dir//'name'//fortran_PS)
       end subroutine

       subroutine make_IO_dir_PCG_solver_SF(this,dir)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         character(len=*),intent(in) :: dir
         call suppress_warnings(this)
         call make_dir_quiet(dir)
         call init(this%dir,dir)
         call init(this%name,'primitives')
         call make_IO_dir(this%MFP,dir//'MFP'//fortran_PS)
         call make_IO_dir(this%norm,dir//'norm'//fortran_PS)
         call make_IO_dir(this%ISP,dir//'ISP'//fortran_PS)
         call make_IO_dir(this%dir,dir//'dir'//fortran_PS)
         call make_IO_dir(this%name,dir//'name'//fortran_PS)
       end subroutine

       subroutine export_structured_D_PCG_solver_SF(this,dir)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = new_and_open(dir,'primitives')
         call export_primitives(this,un)
         close(un)
         call export_structured(this%MFP,dir//'MFP'//fortran_PS)
         call export_structured(this%norm,dir//'norm'//fortran_PS)
         call export_structured(this%ISP,dir//'ISP'//fortran_PS)
         call export_structured(this%dir,dir//'dir'//fortran_PS)
         call export_structured(this%name,dir//'name'//fortran_PS)
       end subroutine

       subroutine import_structured_D_PCG_solver_SF(this,dir)
         implicit none
         type(PCG_solver_SF),intent(inout) :: this
         character(len=*),intent(in) :: dir
         integer :: un
         un = open_to_read(dir,'primitives')
         call import_primitives(this,un)
         close(un)
         call import_structured(this%MFP,dir//'MFP'//fortran_PS)
         call import_structured(this%norm,dir//'norm'//fortran_PS)
         call import_structured(this%ISP,dir//'ISP'//fortran_PS)
         call import_structured(this%dir,dir//'dir'//fortran_PS)
         call import_structured(this%name,dir//'name'//fortran_PS)
       end subroutine

       subroutine suppress_warnings_PCG_solver_SF(this)
         implicit none
         type(PCG_solver_SF),intent(in) :: this
         if (.false.) then
           call print(this)
         endif
       end subroutine

       end module