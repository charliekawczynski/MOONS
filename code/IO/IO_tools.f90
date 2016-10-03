      module IO_tools_mod
      use current_precision_mod
      use string_mod
      use inquire_funcs_mod
      use IO_check_mod
      implicit none

      private

      public :: get_file_unit
      public :: new_and_open,close_and_message
      public :: rewind_unit
      public :: open_to_read,open_to_write,open_to_append

      character(len=4),parameter :: dot_dat = '.dat'

      contains

      function get_file_unit(dir,name) result(un)
        implicit none
        character(len=*),intent(in) :: dir,name
        integer :: un
        type(string) :: s
#ifdef _DEBUG_IO_TOOLS_
        call check_file_exists(dir,name,'get_file_unit')
#endif
        call init(s,dir//name//dot_dat)
        inquire(file=str(s),number=un)
        call delete(s)
      end function

      ! ************************* NEW UNIT *************************
      ! ************************* NEW UNIT *************************
      ! ************************* NEW UNIT *************************

      function new_unit() result(nu)
        implicit none
        integer,parameter :: lun_min=10,lun_max=1000
        integer :: lun,nu
        nu=-1
        do lun=lun_min,lun_max
          if (.not.unit_open(lun)) then; nu=lun; exit; endif
        enddo
      end function

      function new_and_open(dir,name) result(un)
        implicit none
        character(len=*),intent(in) :: dir,name
        integer :: un
        type(string) :: s
        call init(s,dir//name//dot_dat)
        un = new_unit()
        ! open(un,file=str(s),pad='YES',action='readwrite')
        call attempt_to_open_to_write(un,s)
        call delete(s)
      end function

      subroutine attempt_to_open_to_write(un,s)
        implicit none
        integer,intent(in) :: un
        type(string),intent(in) :: s
        integer :: n,i
        logical :: failed
        failed = .true.
        do n=1,100000
          open(un,file=str(s),pad='YES',action='readwrite',iostat=i)
          if (i.eq.0) then; failed = .false.; exit; endif
        enddo
        if (failed) then
          write(*,*) 'Error: tried to open file but failed!!'
          stop 'Done in attempt_to_open_to_write in IO_tools.f90'
        endif
      end subroutine

      ! ************************* CLOSE UNIT *************************
      ! ************************* CLOSE UNIT *************************
      ! ************************* CLOSE UNIT *************************

      subroutine close_and_message(un,dir,name)
        implicit none
        integer,intent(in) :: un
        character(len=*),intent(in) :: dir,name
#ifdef _DEBUG_IO_TOOLS_
        call check_file_exists(dir,name,'close_and_message')
        call check_file_open(dir,name,'close_and_message')
#endif
        close(un)
#ifndef _OPTIMIZE_IO_TOOLS_
        write(*,*) '+++ Closed file ' // dir // name
#endif
      end subroutine

      ! **************************** REWIND ****************************
      ! **************************** REWIND ****************************
      ! **************************** REWIND ****************************

      subroutine rewind_unit(un)
        implicit none
        integer,intent(in) :: un
#ifdef _DEBUG_IO_TOOLS_
        call check_unit_exists(un,'rewind_unit')
        call check_unit_open(un,'rewind_unit')
#endif
        rewind(un)
      end subroutine

      ! *************************** OPEN UNIT ***************************
      ! *************************** OPEN UNIT ***************************
      ! *************************** OPEN UNIT ***************************

      function open_to_read(dir,name) result(un)
        implicit none
        character(len=*),intent(in) :: dir,name
        integer :: un
        type(string) :: s
        call init(s,dir//name//dot_dat)
        un = new_unit()
#ifdef _DEBUG_IO_TOOLS_
        call check_file_exists(dir,name,'open_to_read')
        call check_file_closed(dir,name,'open_to_read')
#endif
        open(un,file=str(s),status = 'old',action = 'read')
        call delete(s)
      end function

      function open_to_write(dir,name) result(un)
        implicit none
        character(len=*),intent(in) :: dir,name
        integer :: un
#ifdef _DEBUG_IO_TOOLS_
        call check_file_exists(dir,name,'open_to_write')
        call check_file_closed(dir,name,'open_to_write')
#endif
        un = new_unit()
        open(unit=un,status='old',action='write')
      end function

      function open_to_append(dir,name) result(un)
        implicit none
        character(len=*),intent(in) :: dir,name
        integer :: un
        type(string) :: s
        call init(s,dir//name//dot_dat)
#ifdef _DEBUG_IO_TOOLS_
        call check_file_exists(dir,name,'open_to_append')
        call check_file_closed(dir,name,'open_to_append')
#endif
        un = new_unit()
        open(unit=un,file=str(s),status='old',action='write',position='append')
      end function

      end module