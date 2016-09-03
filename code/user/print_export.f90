       module print_export_mod
       implicit none
       private
       public :: print_export
       public :: init
       ! public :: init,delete,display,print,export,import

       interface init;     module procedure init_PE;   end interface

       type print_export
         logical :: solution
         logical :: info
         logical :: transient_0D
         logical :: transient_2D
       end type

       contains

       subroutine init_PE(PE,n_step,export_planar)
         implicit none
         type(print_export),intent(inout) :: PE
         integer,intent(in) :: n_step
         logical,intent(in) :: export_planar
         logical,dimension(6) :: temp,temp_half,temp_more_frequent
         integer :: i
         temp = (/((mod(n_step,10**i).eq.1).and.(n_step.ne.1),i=1,6)/)
         temp_half = (/((mod(n_step/2,10**i).eq.1).and.(n_step.ne.1),i=1,6)/)
         temp_more_frequent = temp.or.temp_half

         PE%info = temp(1)
         PE%transient_0D = temp(1)
         PE%transient_2D = export_planar.and.(temp(5).or.n_step.eq.1)
         ! PE%transient_2D = .false.
         PE%solution = temp(6).and.(n_step.gt.1)
       end subroutine

       end module