       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module face_SD_mod
       use current_precision_mod
       use IO_tools_mod
       use index_2D_mod
       use sub_domain_mod
       implicit none

       private
       public :: face_SD
       public :: init,delete,display,print,export,import
       public :: display_short,print_short

       interface init;         module procedure init_copy_face_SD;      end interface
       interface delete;       module procedure delete_face_SD;         end interface
       interface display;      module procedure display_face_SD;        end interface
       interface display_short;module procedure display_short_face_SD;  end interface
       interface display;      module procedure display_wrapper_face_SD;end interface
       interface print;        module procedure print_face_SD;          end interface
       interface print_short;  module procedure print_short_face_SD;    end interface
       interface export;       module procedure export_face_SD;         end interface
       interface import;       module procedure import_face_SD;         end interface
       interface export;       module procedure export_wrapper_face_SD; end interface
       interface import;       module procedure import_wrapper_face_SD; end interface

       type face_SD
         integer :: s = 0
         type(sub_domain),dimension(6) :: G
         type(sub_domain),dimension(6) :: G_periodic_N
         type(sub_domain),dimension(6) :: B
         type(sub_domain),dimension(6) :: I
         type(sub_domain),dimension(6) :: I_OPP
         type(sub_domain),dimension(6) :: I_OPP_periodic_N
         type(index_2D),dimension(6) :: i_2D
         real(cp),dimension(6) :: dh = 0.0_cp
         real(cp),dimension(6) :: nhat = 0.0_cp
         real(cp),dimension(6) :: c_w = 0.0_cp
         real(cp),dimension(6) :: Robin_coeff = 0.0_cp
       end type

       contains

       subroutine init_copy_face_SD(this,that)
         implicit none
         type(face_SD),intent(inout) :: this
         type(face_SD),intent(in) :: that
         integer :: i_G
         integer :: i_G_periodic_N
         integer :: i_B
         integer :: i_I
         integer :: i_I_OPP
         integer :: i_I_OPP_periodic_N
         integer :: i_i_2D
         integer :: s_G
         integer :: s_G_periodic_N
         integer :: s_B
         integer :: s_I
         integer :: s_I_OPP
         integer :: s_I_OPP_periodic_N
         integer :: s_i_2D
         call delete(this)
         this%s = that%s
         s_G = size(that%G)
         do i_G=1,s_G
           call init(this%G(i_G),that%G(i_G))
         enddo
         s_G_periodic_N = size(that%G_periodic_N)
         do i_G_periodic_N=1,s_G_periodic_N
           call init(this%G_periodic_N(i_G_periodic_N),that%G_periodic_N(i_G_periodic_N))
         enddo
         s_B = size(that%B)
         do i_B=1,s_B
           call init(this%B(i_B),that%B(i_B))
         enddo
         s_I = size(that%I)
         do i_I=1,s_I
           call init(this%I(i_I),that%I(i_I))
         enddo
         s_I_OPP = size(that%I_OPP)
         do i_I_OPP=1,s_I_OPP
           call init(this%I_OPP(i_I_OPP),that%I_OPP(i_I_OPP))
         enddo
         s_I_OPP_periodic_N = size(that%I_OPP_periodic_N)
         do i_I_OPP_periodic_N=1,s_I_OPP_periodic_N
           call init(this%I_OPP_periodic_N(i_I_OPP_periodic_N),that%I_OPP_periodic_N(i_I_OPP_periodic_N))
         enddo
         s_i_2D = size(that%i_2D)
         do i_i_2D=1,s_i_2D
           call init(this%i_2D(i_i_2D),that%i_2D(i_i_2D))
         enddo
         this%dh = that%dh
         this%nhat = that%nhat
         this%c_w = that%c_w
         this%Robin_coeff = that%Robin_coeff
       end subroutine

       subroutine delete_face_SD(this)
         implicit none
         type(face_SD),intent(inout) :: this
         integer :: i_G
         integer :: i_G_periodic_N
         integer :: i_B
         integer :: i_I
         integer :: i_I_OPP
         integer :: i_I_OPP_periodic_N
         integer :: i_i_2D
         integer :: s_G
         integer :: s_G_periodic_N
         integer :: s_B
         integer :: s_I
         integer :: s_I_OPP
         integer :: s_I_OPP_periodic_N
         integer :: s_i_2D
         this%s = 0
         s_G = size(this%G)
         do i_G=1,s_G
           call delete(this%G(i_G))
         enddo
         s_G_periodic_N = size(this%G_periodic_N)
         do i_G_periodic_N=1,s_G_periodic_N
           call delete(this%G_periodic_N(i_G_periodic_N))
         enddo
         s_B = size(this%B)
         do i_B=1,s_B
           call delete(this%B(i_B))
         enddo
         s_I = size(this%I)
         do i_I=1,s_I
           call delete(this%I(i_I))
         enddo
         s_I_OPP = size(this%I_OPP)
         do i_I_OPP=1,s_I_OPP
           call delete(this%I_OPP(i_I_OPP))
         enddo
         s_I_OPP_periodic_N = size(this%I_OPP_periodic_N)
         do i_I_OPP_periodic_N=1,s_I_OPP_periodic_N
           call delete(this%I_OPP_periodic_N(i_I_OPP_periodic_N))
         enddo
         s_i_2D = size(this%i_2D)
         do i_i_2D=1,s_i_2D
           call delete(this%i_2D(i_i_2D))
         enddo
         this%dh = 0.0_cp
         this%nhat = 0.0_cp
         this%c_w = 0.0_cp
         this%Robin_coeff = 0.0_cp
       end subroutine

       subroutine display_face_SD(this,un)
         implicit none
         type(face_SD),intent(in) :: this
         integer,intent(in) :: un
         integer :: i_G
         integer :: i_G_periodic_N
         integer :: i_B
         integer :: i_I
         integer :: i_I_OPP
         integer :: i_I_OPP_periodic_N
         integer :: i_i_2D
         integer :: s_G
         integer :: s_G_periodic_N
         integer :: s_B
         integer :: s_I
         integer :: s_I_OPP
         integer :: s_I_OPP_periodic_N
         integer :: s_i_2D
         write(un,*) ' -------------------- face_SD'
         write(un,*) 's                = ',this%s
         s_G = size(this%G)
         do i_G=1,s_G
           call display(this%G(i_G),un)
         enddo
         s_G_periodic_N = size(this%G_periodic_N)
         do i_G_periodic_N=1,s_G_periodic_N
           call display(this%G_periodic_N(i_G_periodic_N),un)
         enddo
         s_B = size(this%B)
         do i_B=1,s_B
           call display(this%B(i_B),un)
         enddo
         s_I = size(this%I)
         do i_I=1,s_I
           call display(this%I(i_I),un)
         enddo
         s_I_OPP = size(this%I_OPP)
         do i_I_OPP=1,s_I_OPP
           call display(this%I_OPP(i_I_OPP),un)
         enddo
         s_I_OPP_periodic_N = size(this%I_OPP_periodic_N)
         do i_I_OPP_periodic_N=1,s_I_OPP_periodic_N
           call display(this%I_OPP_periodic_N(i_I_OPP_periodic_N),un)
         enddo
         s_i_2D = size(this%i_2D)
         do i_i_2D=1,s_i_2D
           call display(this%i_2D(i_i_2D),un)
         enddo
         write(un,*) 'dh               = ',this%dh
         write(un,*) 'nhat             = ',this%nhat
         write(un,*) 'c_w              = ',this%c_w
         write(un,*) 'Robin_coeff      = ',this%Robin_coeff
       end subroutine

       subroutine display_short_face_SD(this,un)
         implicit none
         type(face_SD),intent(in) :: this
         integer,intent(in) :: un
         integer :: i_G
         integer :: i_G_periodic_N
         integer :: i_B
         integer :: i_I
         integer :: i_I_OPP
         integer :: i_I_OPP_periodic_N
         integer :: i_i_2D
         integer :: s_G
         integer :: s_G_periodic_N
         integer :: s_B
         integer :: s_I
         integer :: s_I_OPP
         integer :: s_I_OPP_periodic_N
         integer :: s_i_2D
         write(un,*) 's                = ',this%s
         s_G = size(this%G)
         do i_G=1,s_G
           call display(this%G(i_G),un)
         enddo
         s_G_periodic_N = size(this%G_periodic_N)
         do i_G_periodic_N=1,s_G_periodic_N
           call display(this%G_periodic_N(i_G_periodic_N),un)
         enddo
         s_B = size(this%B)
         do i_B=1,s_B
           call display(this%B(i_B),un)
         enddo
         s_I = size(this%I)
         do i_I=1,s_I
           call display(this%I(i_I),un)
         enddo
         s_I_OPP = size(this%I_OPP)
         do i_I_OPP=1,s_I_OPP
           call display(this%I_OPP(i_I_OPP),un)
         enddo
         s_I_OPP_periodic_N = size(this%I_OPP_periodic_N)
         do i_I_OPP_periodic_N=1,s_I_OPP_periodic_N
           call display(this%I_OPP_periodic_N(i_I_OPP_periodic_N),un)
         enddo
         s_i_2D = size(this%i_2D)
         do i_i_2D=1,s_i_2D
           call display(this%i_2D(i_i_2D),un)
         enddo
         write(un,*) 'dh               = ',this%dh
         write(un,*) 'nhat             = ',this%nhat
         write(un,*) 'c_w              = ',this%c_w
         write(un,*) 'Robin_coeff      = ',this%Robin_coeff
       end subroutine

       subroutine print_face_SD(this)
         implicit none
         type(face_SD),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine print_short_face_SD(this)
         implicit none
         type(face_SD),intent(in) :: this
         call display_short(this,6)
       end subroutine

       subroutine export_face_SD(this,un)
         implicit none
         type(face_SD),intent(in) :: this
         integer,intent(in) :: un
         integer :: i_G
         integer :: i_G_periodic_N
         integer :: i_B
         integer :: i_I
         integer :: i_I_OPP
         integer :: i_I_OPP_periodic_N
         integer :: i_i_2D
         integer :: s_G
         integer :: s_G_periodic_N
         integer :: s_B
         integer :: s_I
         integer :: s_I_OPP
         integer :: s_I_OPP_periodic_N
         integer :: s_i_2D
         write(un,*) 's                 = ';write(un,*) this%s
         s_G = size(this%G)
         write(un,*) s_G
         do i_G=1,s_G
           call export(this%G(i_G),un)
         enddo
         s_G_periodic_N = size(this%G_periodic_N)
         write(un,*) s_G_periodic_N
         do i_G_periodic_N=1,s_G_periodic_N
           call export(this%G_periodic_N(i_G_periodic_N),un)
         enddo
         s_B = size(this%B)
         write(un,*) s_B
         do i_B=1,s_B
           call export(this%B(i_B),un)
         enddo
         s_I = size(this%I)
         write(un,*) s_I
         do i_I=1,s_I
           call export(this%I(i_I),un)
         enddo
         s_I_OPP = size(this%I_OPP)
         write(un,*) s_I_OPP
         do i_I_OPP=1,s_I_OPP
           call export(this%I_OPP(i_I_OPP),un)
         enddo
         s_I_OPP_periodic_N = size(this%I_OPP_periodic_N)
         write(un,*) s_I_OPP_periodic_N
         do i_I_OPP_periodic_N=1,s_I_OPP_periodic_N
           call export(this%I_OPP_periodic_N(i_I_OPP_periodic_N),un)
         enddo
         s_i_2D = size(this%i_2D)
         write(un,*) s_i_2D
         do i_i_2D=1,s_i_2D
           call export(this%i_2D(i_i_2D),un)
         enddo
         write(un,*) 'dh                = ';write(un,*) this%dh
         write(un,*) 'nhat              = ';write(un,*) this%nhat
         write(un,*) 'c_w               = ';write(un,*) this%c_w
         write(un,*) 'Robin_coeff       = ';write(un,*) this%Robin_coeff
       end subroutine

       subroutine import_face_SD(this,un)
         implicit none
         type(face_SD),intent(inout) :: this
         integer,intent(in) :: un
         integer :: i_G
         integer :: i_G_periodic_N
         integer :: i_B
         integer :: i_I
         integer :: i_I_OPP
         integer :: i_I_OPP_periodic_N
         integer :: i_i_2D
         integer :: s_G
         integer :: s_G_periodic_N
         integer :: s_B
         integer :: s_I
         integer :: s_I_OPP
         integer :: s_I_OPP_periodic_N
         integer :: s_i_2D
         call delete(this)
         read(un,*); read(un,*) this%s
         read(un,*) s_G
         do i_G=1,s_G
           call import(this%G(i_G),un)
         enddo
         read(un,*) s_G_periodic_N
         do i_G_periodic_N=1,s_G_periodic_N
           call import(this%G_periodic_N(i_G_periodic_N),un)
         enddo
         read(un,*) s_B
         do i_B=1,s_B
           call import(this%B(i_B),un)
         enddo
         read(un,*) s_I
         do i_I=1,s_I
           call import(this%I(i_I),un)
         enddo
         read(un,*) s_I_OPP
         do i_I_OPP=1,s_I_OPP
           call import(this%I_OPP(i_I_OPP),un)
         enddo
         read(un,*) s_I_OPP_periodic_N
         do i_I_OPP_periodic_N=1,s_I_OPP_periodic_N
           call import(this%I_OPP_periodic_N(i_I_OPP_periodic_N),un)
         enddo
         read(un,*) s_i_2D
         do i_i_2D=1,s_i_2D
           call import(this%i_2D(i_i_2D),un)
         enddo
         read(un,*); read(un,*) this%dh
         read(un,*); read(un,*) this%nhat
         read(un,*); read(un,*) this%c_w
         read(un,*); read(un,*) this%Robin_coeff
       end subroutine

       subroutine display_wrapper_face_SD(this,dir,name)
         implicit none
         type(face_SD),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine export_wrapper_face_SD(this,dir,name)
         implicit none
         type(face_SD),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrapper_face_SD(this,dir,name)
         implicit none
         type(face_SD),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = open_to_read(dir,name)
         call import(this,un)
         close(un)
       end subroutine

       end module