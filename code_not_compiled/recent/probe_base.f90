       module probe_base_mod
       ! Implementation:
       ! 
       ! indexProbe:
       !       type(indexProbe) :: p                              ! 
       !       call init(p,g,s,i,dir,name,TF_freshStart)          ! enables other routines
       !       call resetH(p,h)                                   ! if h needs to be reset
       !       call print(p)                                      ! prints basic info (no data)
       !       call export(p)                                     ! exports basic probe info (no data)
       ! 
       !       do i=1,1000
       !         call set(p,n,d)                                  ! sets data to be exported
       !         call set(p,n,u)                                  ! sets data to be exported
       !         call apply(p)                                    ! exports transient data (n,d)
       !       enddo
       ! 
       ! errorProbe:
       !       type(errorProbe) :: p                              ! 
       !       call init(p,dir,name,TF_freshStart)                ! enables other routines
       !       call resetH(p,h)                                   ! if h needs to be reset
       !       call print(p)                                      ! prints basic info (no data)
       !       call export(p)                                     ! exports basic probe info (no data)
       ! 
       !       do i=1,1000
       !         call set(p,n,u)                                  ! sets data to be exported
       !         call set(p,n,d)                                  ! sets data to be exported
       !         call apply(p)                                    ! exports transient data (n,d)
       !       enddo
       ! 
       ! NOTE: init prints the index location if one exists.
       ! 
       use current_precision_mod
       use string_mod
       use probe_transient_mod
       use IO_tools_mod
       use mesh_mod
       use norms_mod
       use SF_mod

       implicit none

       private
       public :: indexProbe,errorProbe
       public :: init,set,apply
       public :: export, print
       public :: defineH,resetH,delete

       type indexProbe
         type(probe) :: p                             ! probe
         real(cp),dimension(3) :: h                   ! probe location
         integer,dimension(3) :: i                    ! index of location
       end type

       type errorProbe
         type(probe) :: p                             ! probe
         type(norms) :: e                             ! for computing data
       end type

       interface init;          module procedure initIndexProbe;            end interface
       interface init;          module procedure initErrorProbe;            end interface

       interface set;           module procedure setIndexData;              end interface
       interface set;           module procedure setIndexData1;             end interface

       interface set;           module procedure setErrorData;              end interface
       interface set;           module procedure setErrorData_SF;           end interface

       interface apply;         module procedure applyIndexProbe;           end interface
       interface apply;         module procedure applyErrorProbe;           end interface

       interface apply;         module procedure setApplyIndexProbe;        end interface
       interface apply;         module procedure setApplyErrorProbe;        end interface

       interface print;         module procedure printIndexProbe;           end interface
       interface print;         module procedure printErrorProbe;           end interface

       interface export;        module procedure exportIndexProbe;          end interface
       interface export;        module procedure exportErrorProbe;          end interface

       interface delete;        module procedure deleteIndexProbe;          end interface
       interface delete;        module procedure deleteErrorProbe;          end interface

       contains

        subroutine initIndexProbe(ip,dir,name,TF_freshStart,s,i,m)
          implicit none
          type(indexProbe),intent(inout) :: ip
          type(mesh),intent(in) :: m
          integer,dimension(3),intent(in) :: s,i
          character(len=*),intent(in) :: dir
          character(len=*),intent(in) :: name
          logical,intent(in) :: TF_freshStart
          integer :: k
          call init(ip%p,dir,name,TF_freshStart)
          call defineH(i,m,s,ip%h)
          ip%i = (/(maxval((/i(k),1/)),k=1,3)/)
        end subroutine

        subroutine initErrorProbe(ep,dir,name,TF_freshStart)
          implicit none
          type(errorProbe),intent(inout) :: ep
          character(len=*),intent(in) :: dir
          character(len=*),intent(in) :: name
          logical,intent(in) :: TF_freshStart
          call init(ep%p,dir,name,TF_freshStart)
        end subroutine

        subroutine resetH(ip,h)
         implicit none
          type(indexProbe),intent(inout) :: ip
          real(cp),dimension(3),intent(in) :: h
          ip%h = h
        end subroutine

        subroutine setIndexData(ip,n,t,d)
         implicit none
          type(indexProbe),intent(inout) :: ip
          integer,intent(in) :: n
          real(cp),intent(in) :: t
          real(cp),intent(in) :: d
          call set(ip%p,n,t,d)
        end subroutine

        subroutine setIndexData1(ip,n,t,u)
         implicit none
          type(indexProbe),intent(inout) :: ip
          integer,intent(in) :: n
          real(cp),intent(in) :: t
          real(cp),dimension(:,:,:),intent(in) :: u
          integer,dimension(3) :: temp
          temp(1) = maxval((/ip%i(1),1/))
          temp(2) = maxval((/ip%i(2),1/))
          temp(3) = maxval((/ip%i(3),1/))
          call set(ip%p,n,t,u(temp(1),temp(2),temp(3)))
        end subroutine

        subroutine setErrorData(ep,n,t,d)
         implicit none
          type(errorProbe),intent(inout) :: ep
          integer,intent(in) :: n
          real(cp),intent(in) :: t,d
          call set(ep%p,n,t,d)
        end subroutine

        subroutine setErrorData_SF(ep,n,t,u,vol)
         implicit none
          type(errorProbe),intent(inout) :: ep
          integer,intent(in) :: n
          real(cp),intent(in) :: t
          type(SF),intent(in) :: u,vol
          call compute(ep%e,u,vol)
          call set(ep%p,n,t,ep%e%L2)
        end subroutine

        subroutine applyIndexProbe(ip,n,t,u)
         implicit none
          type(indexProbe),intent(inout) :: ip
          integer,intent(in) :: n
          real(cp),intent(in) :: t
          real(cp),dimension(:,:,:),intent(in) :: u
          call set(ip,n,t,u)
          call apply(ip%p)
        end subroutine

        subroutine setApplyIndexProbe(ip)
         implicit none
          type(indexProbe),intent(inout) :: ip
          call apply(ip%p)
        end subroutine

        subroutine applyErrorProbe(ep)
         implicit none
          type(errorProbe),intent(inout) :: ep
          call apply(ep%p)
        end subroutine

        subroutine setApplyErrorProbe(ep,n,t,u,vol)
         implicit none
          type(errorProbe),intent(inout) :: ep
          integer,intent(in) :: n
          real(cp),intent(in) :: t
          type(SF),intent(in) :: u,vol
          call set(ep,n,t,u,vol)
          call apply(ep%p)
        end subroutine

        subroutine defineH(i,m,s,h)
         implicit none
          integer,dimension(3),intent(in) :: i
          type(mesh),intent(in) :: m
          integer,dimension(3),intent(in) :: s
          real(cp),dimension(3),intent(inout) :: h
          h = 0
          if (s(1).eq.m%g(1)%c(1)%sc) h(1) = m%g(1)%c(1)%hc(i(1))
          if (s(1).eq.m%g(1)%c(1)%sc) h(1) = m%g(1)%c(1)%hc(i(1))
          if (s(2).eq.m%g(1)%c(2)%sc) h(2) = m%g(1)%c(2)%hc(i(2))
          if (s(2).eq.m%g(1)%c(2)%sc) h(2) = m%g(1)%c(2)%hc(i(2))
          if (s(3).eq.m%g(1)%c(3)%sc) h(3) = m%g(1)%c(3)%hc(i(3))
          if (s(3).eq.m%g(1)%c(3)%sc) h(3) = m%g(1)%c(3)%hc(i(3))

          if (s(1).eq.m%g(1)%c(1)%sn) h(1) = m%g(1)%c(1)%hn(i(1))
          if (s(1).eq.m%g(1)%c(1)%sn) h(1) = m%g(1)%c(1)%hn(i(1))
          if (s(2).eq.m%g(1)%c(2)%sn) h(2) = m%g(1)%c(2)%hn(i(2))
          if (s(2).eq.m%g(1)%c(2)%sn) h(2) = m%g(1)%c(2)%hn(i(2))
          if (s(3).eq.m%g(1)%c(3)%sn) h(3) = m%g(1)%c(3)%hn(i(3))
          if (s(3).eq.m%g(1)%c(3)%sn) h(3) = m%g(1)%c(3)%hn(i(3))
        end subroutine

        ! ------------------ PRINT / EXPORT PROBE --------------------- index probe

       subroutine printIndexProbe(ip,u)
         implicit none
         type(indexProbe), intent(in) :: ip
         integer,intent(in),optional :: u
         if (.not.present(u)) then
           write(*,*) ' ---------- INDEX PROBE ---------'
           call printProbe(ip%p,6)
           call writeIndexProbeToFileOrScreen(ip,6)
         else
           call printProbe(ip%p,u)
           call writeIndexProbeToFileOrScreen(ip,u)
         endif
       end subroutine

       subroutine exportIndexProbe(ip,u)
         implicit none
         type(indexProbe), intent(in) :: ip
         integer,intent(in),optional :: u
         integer :: newU
         if (.not.present(u)) then
          newU = new_and_open(str(ip%p%dir),str(ip%p%name)//'_info')
           write(newU,*) ' ---------------- INDEX PROBE -------------- '
         else; newU = u
         endif

         call export(ip%p,newU)
         call writeIndexProbeToFileOrScreen(ip,newU)
         if (.not.present(u)) then
           call close_and_message(newU,str(ip%p%dir),str(ip%p%name)//'_info')
         endif
       end subroutine

       subroutine writeIndexProbeToFileOrScreen(ip,u)
         implicit none
         type(indexProbe), intent(in) :: ip
         integer,intent(in) :: u
         write(u,*) ' index = ',ip%i
         write(u,*) ' location = ',ip%h
       end subroutine

        ! ------------------ PRINT / EXPORT PROBE --------------------- error probe

       subroutine printErrorProbe(ep,u)
         implicit none
         type(errorProbe), intent(in) :: ep
         integer,intent(in),optional :: u
         if (.not.present(u)) then
           write(*,*) ' ---------- ERROR PROBE ---------'
           call printProbe(ep%p,6)
         else
           call printProbe(ep%p)
         endif
       end subroutine

       subroutine exportErrorProbe(ep,u)
         implicit none
         type(errorProbe), intent(in) :: ep
         integer,intent(in),optional :: u
         integer :: newU
         if (.not.present(u)) then
           newU = new_and_open(str(ep%p%dir),str(ep%p%name)//'_info')
           write(newU,*) ' ---------------- ERROR PROBE -------------- '
         else; newU = u
         endif

         call export(ep%p,newU)

         if (.not.present(u)) then
           call close_and_message(newU,str(ep%p%dir),str(ep%p%name)//'_info')
         endif
       end subroutine

       subroutine deleteIndexProbe(ip)
         implicit none
         type(indexProbe),intent(inout) :: ip
         call delete(ip%p)
       end subroutine

       subroutine deleteErrorProbe(ep)
         implicit none
         type(errorProbe),intent(inout) :: ep
         call delete(ep%p)
       end subroutine

       end module