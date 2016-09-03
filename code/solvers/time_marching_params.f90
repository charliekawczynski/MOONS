       module time_marching_params_mod
       use current_precision_mod
       use string_mod
       use IO_tools_mod
       implicit none

       private
       public :: time_marching_params
       public :: init,delete,export,import,display,print
       public :: iterate_step

       type time_marching_params
         integer :: n_step        ! nth time step
         integer :: n_step_stop   ! nth time step to stop
         integer :: n_step_start  ! nth time step to start
         real(cp) :: t            ! time, or pseudo time
         real(cp) :: dt           ! time step, or pseudo time step
         integer :: un            ! file unit
         type(string) :: dir,name ! directory / name
       end type

       interface init;         module procedure init_TMP;         end interface
       interface init;         module procedure init_copy_TMP;    end interface
       interface delete;       module procedure delete_TMP;       end interface
       interface export;       module procedure export_TMP;       end interface
       interface import;       module procedure import_TMP;       end interface
       interface display;      module procedure display_TMP;      end interface
       interface print;        module procedure print_TMP;        end interface

       interface iterate_step; module procedure iterate_step_TMP; end interface

       contains

       ! **********************************************************
       ! ********************* ESSENTIALS *************************
       ! **********************************************************

       subroutine init_TMP(TMP,n_step_stop,dt,dir,name)
         implicit none
         type(time_marching_params),intent(inout) :: TMP
         integer,intent(in) :: n_step_stop
         real(cp),intent(in) :: dt
         character(len=*),intent(in) :: dir,name
         TMP%n_step_start = 0
         TMP%n_step = 0
         TMP%n_step_stop = n_step_stop
         TMP%t = 0.0_cp
         TMP%dt = dt
         call init(TMP%dir,dir)
         call init(TMP%name,name)
         ! TMP%un = newAndOpen(str(TMP%dir),str(TMP%name))
       end subroutine

       subroutine init_copy_TMP(TMP_out,TMP_in)
         implicit none
         type(time_marching_params),intent(inout) :: TMP_out
         type(time_marching_params),intent(in) :: TMP_in
         TMP_out%n_step_start = TMP_in%n_step_start
         TMP_out%n_step = TMP_in%n_step
         TMP_out%n_step_stop = TMP_in%n_step_stop
         TMP_out%t = TMP_in%t
         TMP_out%dt = TMP_in%dt
         call init(TMP_out%dir,TMP_in%dir)
         call init(TMP_out%name,TMP_in%name)
         TMP_out%un = TMP_in%un
       end subroutine

       subroutine delete_TMP(TMP)
         implicit none
         type(time_marching_params),intent(inout) :: TMP
         TMP%n_step_start = 0
         TMP%n_step = 0
         TMP%n_step_stop = 1
         TMP%t = 0.0_cp
         TMP%dt = 10.0_cp**(-10.0_cp)
         ! prefer closeAndMessage, but not all copies are initialized, and fail to have dir / name
         ! call closeAndMessage(TMP%un,str(TMP%dir),str(TMP%name))
         close(TMP%un)
         call delete(TMP%dir)
         call delete(TMP%name)
         TMP%un = 0
       end subroutine

       subroutine export_TMP(TMP)
         implicit none
         type(time_marching_params),intent(in) :: TMP
         integer :: un
         un = newAndOpen(str(TMP%dir),str(TMP%name))
         write(un,*) 'n_step_start = ';write(un,*) TMP%n_step_start
         write(un,*) 'n_step = ';      write(un,*) TMP%n_step
         write(un,*) 'n_step_stop = '; write(un,*) TMP%n_step_stop
         write(un,*) 't = ';           write(un,*) TMP%t
         write(un,*) 'dt = ';          write(un,*) TMP%dt
         close(un)
       end subroutine

       subroutine import_TMP(TMP)
         implicit none
         type(time_marching_params),intent(inout) :: TMP
         TMP%un = openToRead(str(TMP%dir),str(TMP%name))
         read(TMP%un,*); read(TMP%un,*) TMP%n_step_start
         read(TMP%un,*); read(TMP%un,*) TMP%n_step
         read(TMP%un,*); read(TMP%un,*) TMP%n_step_stop
         read(TMP%un,*); read(TMP%un,*) TMP%t
         read(TMP%un,*); read(TMP%un,*) TMP%dt
         close(TMP%un)
       end subroutine

       subroutine display_TMP(TMP,un)
         implicit none
         type(time_marching_params),intent(in) :: TMP
         integer,intent(in) :: un
         call display(TMP%dir,un)
         call display(TMP%name,un)
         write(un,*) 'n_step_start = ',TMP%n_step_start
         write(un,*) 'n_step = ',TMP%n_step
         write(un,*) 'n_step_stop = ',TMP%n_step_stop
         write(un,*) 't = ',TMP%t
         write(un,*) 'dt = ',TMP%dt
       end subroutine

       subroutine print_TMP(TMP)
         implicit none
         type(time_marching_params),intent(inout) :: TMP
         call display(TMP,6)
       end subroutine

       subroutine iterate_step_TMP(TMP)
         implicit none
         type(time_marching_params),intent(inout) :: TMP
         TMP%n_step = TMP%n_step + 1
         TMP%t = TMP%t + TMP%dt
       end subroutine

       end module