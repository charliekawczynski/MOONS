       module clock_mod
       use current_precision_mod
       implicit none

       private
       public :: clock
       public :: init,delete
       public :: tic,toc

       integer,parameter :: ip = selected_int_kind(16) ! To avoid timer wraparound

       interface init;         module procedure init_clock;          end interface
       interface tic;          module procedure tic_clock;           end interface
       interface toc;          module procedure toc_clock;           end interface
       interface delete;       module procedure delete_clock;        end interface

       type clock
         real(cp) :: t_elapsed
         real(cp),private :: t_start
         real(cp),private :: t_stop
         integer(ip),private :: i_start
         integer(ip),private :: i_stop
         integer(ip),private :: count_rate
       end type

       contains

       subroutine init_clock(c)
         implicit none
         type(clock),intent(inout) :: c
         call delete(c)
       end subroutine

       subroutine tic_clock(c)
         implicit none
         type(clock),intent(inout) :: c
         call system_clock(c%i_start,c%count_rate)
         c%t_start = real(c%i_start,cp)
       end subroutine

       subroutine toc_clock(c)
         implicit none
         type(clock),intent(inout) :: c
         call system_clock(c%i_stop,c%count_rate)
         c%t_stop = real(c%i_stop,cp)
         c%t_elapsed = (c%t_stop - c%t_start)/real(c%count_rate,cp)
       end subroutine

       subroutine delete_clock(c)
         implicit none
         type(clock),intent(inout) :: c
         c%t_start = 0.0_cp
         c%t_stop = 0.0_cp
         c%t_elapsed = 0.0_cp
         c%count_rate = 10
         c%i_start = 0
         c%i_stop = 0
       end subroutine

       end module