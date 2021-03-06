       module version_mod
       use string_mod
       use IO_tools_mod
       implicit none

       private
       public :: export_version
       public :: print_version

       contains

       subroutine export_version(dir)
         implicit none
         character(len=*),intent(in) :: dir
         integer :: NewU
         NewU = new_and_open(dir,'version')
         call export_version_no_dir(newU)
         call close_and_message(newU,dir,'version')
       end subroutine

       subroutine print_version()
         implicit none
         call export_version_no_dir(6)
       end subroutine

       subroutine export_version_no_dir(u)
         implicit none
         integer,intent(in) :: u
         integer :: today(3), now(3)
         ! character(len=5) :: fmt
         write(u,*) '---------------------------------------'
         write(u,*) ' Magnetohydrodynamic Object-Oriented   '
         write(u,*) '    Numerical Solver (MOONS)           '
         write(u,*) '---------------------------------------'
         write(u,*) 'MOONS is a finite difference code that '
         write(u,*) 'solves Navier-Stokes and Maxwells      '
         write(u,*) 'equations in a 3D rectangular geometry.'
         write(u,*) ''
         write(u,*) 'For documentation, navigate to'
         write(u,*) '/MOONS/__documentation/MOONS.pdf'
         write(u,*) '---------------------------------------'

         ! Source: http://infohost.nmt.edu/tcc/help/lang/fortran/date.html

         call idate(today)   ! today(1)=day, (2)=month, (3)=year
         call itime(now)     ! now(1)=hour, (2)=minute, (3)=second
         write ( u, 1000 )  today(2), today(1), today(3), now
    1000 format ( ' Version: ', i2.2, '/', i2.2, '/', i4.4, '; time ',&
                 i2.2, ':', i2.2, ':', i2.2 )

         ! fmt = '(A10,i2.2,A,i2.2,A,i4.4,A6,i2.2,A,i2.2,A,i2.2)'

         ! write(u,fmt) ' Version: ',today(2),'/',today(1),'/',today(3),'; time',now
         write(u,*) '-------------------------------------'
       end subroutine

       end module