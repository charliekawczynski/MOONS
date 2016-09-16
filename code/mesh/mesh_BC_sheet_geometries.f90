       module mesh_BC_sheet_geometries_mod
       use current_precision_mod
       use grid_init_mod
       use grid_extend_mod
       use grid_connect_mod
       use coordinate_stretch_parameters_mod
       use grid_mod
       use domain_mod
       use mesh_mod
       implicit none

       private
       public :: BC_sim_mom_sheet,BC_sim_ind_sheet

       contains

       subroutine BC_sim_mom_sheet(m,Ha)
         implicit none
         type(mesh),intent(inout) :: m
         real(cp),intent(in) :: Ha
         type(grid) :: g
         real(cp),dimension(3) :: hmin,hmax,beta
         integer,dimension(3) :: N
         integer :: i
         call delete(m)
         hmin = -1.0_cp; hmax = 1.0_cp; beta = HartmannBL(Ha,hmin,hmax)
         if (low_Ha(Ha)) then;      N = (/30,30,30/) ! For Ha = 20
         elseif (high_Ha(Ha)) then; N = (/32,32,32/) ! For Ha = 100
         else; stop 'Error: bad input to geometry in BC_sim_mom in mesh_simple_geometries.f90'
         endif
         ! hmin(2) = -0.5_cp
         ! hmax(2) = 0.5_cp
         hmin(2) = -0.005_cp
         hmax(2) = 0.005_cp
         ! hmin(2) = 0.0_cp; hmax(2) = 0.0_cp; N(2) = 0
         i = 1; call grid_Roberts_B(g,hmin(i),hmax(i),N(i),beta(i),i)
         i = 2; call grid_uniform(g,hmin(i),hmax(i),N(i),i)
         i = 3; call grid_Roberts_B(g,hmin(i),hmax(i),N(i),beta(i),i)
         call add(m,g)
         call initProps(m)
         call patch(m)
         call delete(g)
       end subroutine

       subroutine BC_sim_ind_sheet(m_ind,m_mom,D_sigma,Ha,tw,include_vacuum)
         implicit none
         type(mesh),intent(inout) :: m_ind
         type(mesh),intent(in) :: m_mom
         type(domain),intent(inout) :: D_sigma
         real(cp),intent(in) :: Ha,tw
         logical,intent(in) :: include_vacuum
         type(mesh) :: m_sigma
         type(grid) :: g
         real(cp) :: tf
         real(cp) :: Gamma_v
         integer :: N_w,N_v,N_extra
         integer :: i
         call delete(m_ind)
         call init(g,m_mom%g(1))

         Gamma_v = 7.0_cp
         tf = 1.0_cp
         N_w = get_N_w(Ha,tw)
         N_v = 12
         N_extra = 6 ! since no wall domain above lid

         ! Wall
         i = 1; call ext_Roberts_B_IO(g,tw,N_w,i)
         i = 3; call ext_Roberts_B_IO(g,tw,N_w,i)

         ! Define domain for electrical conductivity
         call add(m_sigma,g)
         call initProps(m_sigma)
         call patch(m_sigma)

         ! Vacuum
         ! Remove the following 4 lines for vacuum-absent case
         if (include_vacuum) then
           i=1; call ext_Roberts_near_IO(g,Gamma_v - tw - tf,N_v,i) ! x-direction
           i=3; call ext_Roberts_near_IO(g,Gamma_v - tw - tf,N_v,i) ! z-direction
           i=2; call ext_Roberts_near_IO(g,Gamma_v - tw - tf,N_v+N_extra,i)
         endif

         call add(m_ind,g)
         call initProps(m_ind)
         call patch(m_ind)

         call init(D_sigma,m_sigma,m_ind)
         call delete(m_sigma)
         call delete(g)
       end subroutine

       function get_N_w(Ha,tw) result(N_w)
         implicit none
         real(cp),intent(in) :: Ha,tw
         integer :: N_w
         if (low_tw(tw)) then
           if (low_Ha(Ha)) then;      N_w = 4 ! For Ha = 20
           elseif (high_Ha(Ha)) then; N_w = 6 ! For Ha = 100
           else; write(*,*) 'Ha,tw=',Ha,tw
            stop 'Error: 2 bad input to geometry in BC_sim_ind in mesh_simple_geometries.f90'
           endif
         elseif (high_tw(tw)) then
           if (low_Ha(Ha)) then;      N_w = 8 ! For Ha = 20
           elseif (high_Ha(Ha)) then; N_w = 10 ! For Ha = 100
           else; write(*,*) 'Ha,tw=',Ha,tw
            stop 'Error: 3 bad input to geometry in BC_sim_ind in mesh_simple_geometries.f90'
           endif
         else; write(*,*) 'Ha,tw=',Ha,tw
            stop 'Error: 4 bad input to geometry in BC_sim_ind in mesh_simple_geometries.f90'
         endif
       end function


       function low_Ha(Ha) result(L)
         implicit none
         real(cp),intent(in) :: Ha
         real(cp) :: Ha_target,tol
         logical :: L
         Ha_target = 20.0_cp; tol = 10.0_cp**(-10.0_cp)
         L = (Ha.gt.Ha_target-tol).and.(Ha.lt.Ha_target+tol)
       end function
       function high_Ha(Ha) result(L)
         implicit none
         real(cp),intent(in) :: Ha
         real(cp) :: Ha_target,tol
         logical :: L
         Ha_target = 100.0_cp; tol = 10.0_cp**(-10.0_cp)
         L = (Ha.gt.Ha_target-tol).and.(Ha.lt.Ha_target+tol)
       end function
       function low_tw(tw) result(L)
         implicit none
         real(cp),intent(in) :: tw
         real(cp) :: tw_target,tol
         logical :: L
         tw_target = 0.05_cp; tol = 10.0_cp**(-10.0_cp)
         L = (tw.gt.tw_target-tol).and.(tw.lt.tw_target+tol)
       end function
       function high_tw(tw) result(L)
         implicit none
         real(cp),intent(in) :: tw
         real(cp) :: tw_target,tol
         logical :: L
         tw_target = 0.5_cp; tol = 10.0_cp**(-10.0_cp)
         L = (tw.gt.tw_target-tol).and.(tw.lt.tw_target+tol)
       end function

       end module