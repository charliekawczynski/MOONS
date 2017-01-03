       module grid_connect_mod
       use current_precision_mod
       use coordinates_mod
       use array_mod
       use grid_mod
       use coordinate_distribution_funcs_mod
       use coordinate_stretch_param_match_mod
       implicit none

       private

       public :: con_prep_uniform      ! con_prep_uniform(g,g_in,N,dir)
       public :: con_prep_Roberts_L    ! con_prep_Roberts_L(g,g_in,L,N,dir)
       public :: con_prep_Roberts_R    ! con_prep_Roberts_R(g,g_in,L,N,dir)
       public :: con_prep_Roberts_B    ! con_prep_Roberts_B(g,g_in,L,N,dir)
       ! public :: con_prep_cluster      ! Not yet implemented

       public :: con_app_uniform       ! con_app_uniform(g,g_in,N,dir)
       public :: con_app_Roberts_L     ! con_app_Roberts_L(g,g_in,L,N,dir)
       public :: con_app_Roberts_R     ! con_app_Roberts_R(g,g_in,L,N,dir)
       public :: con_app_Roberts_B     ! con_app_Roberts_B(g,g_in,L,N,dir)
       ! public :: con_app_cluster       ! Not yet implemented

       contains

       subroutine process(g,a,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(array),intent(inout) :: a
         integer,intent(in) :: dir
         call init(g%c(dir),a)
         call add_ghost_nodes(g%c(dir))
         call delete(a)
       end subroutine

       ! ******************************************************************** Prepend

       subroutine con_prep_uniform(g,g_in,N,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: g_in
         integer,intent(in) :: N,dir
         type(array) :: a
         real(cp) :: dh
         call check_N(N,'con_prep_uniform')
         call init(g,g_in)
         dh = g%c(dir)%dhn%f(1)
         call init(a,uniformLeft(g_in%c(dir)%hmin,dh,N))
         call process(g,a,dir)
       end subroutine

       subroutine con_prep_Roberts_L(g,g_in,L,N,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: g_in
         real(cp),intent(in) :: L
         integer,intent(in) :: N,dir
         real(cp) :: beta,hmin
         type(array) :: a
         call check_N(N,'con_prep_Roberts_L')
         call init(g,g_in)
         hmin = g_in%c(dir)%hmin
         beta = beta_dh_small(hmin - L,hmin,N,g_in%c(dir)%dhn%f(1))
         call init(a,robertsLeft(hmin-L,hmin,N,beta))
         call process(g,a,dir)
       end subroutine

       subroutine con_prep_Roberts_R(g,g_in,L,N,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: g_in
         real(cp),intent(in) :: L
         integer,intent(in) :: N,dir
         real(cp) :: beta,hmin
         type(array) :: a
         call check_N(N,'con_prep_Roberts_R')
         call init(g,g_in)
         hmin = g_in%c(dir)%hmin
         beta = beta_dh_small(hmin - L,hmin,N,g_in%c(dir)%dhn%f(1))
         call init(a,robertsRight(hmin-L,hmin,N,beta))
         call process(g,a,dir)
       end subroutine

       subroutine con_prep_Roberts_B(g,g_in,L,N,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: g_in
         real(cp),intent(in) :: L
         integer,intent(in) :: N,dir
         real(cp) :: beta,hmin
         type(array) :: a
         call check_N(N,'con_prep_Roberts_B')
         call init(g,g_in)
         hmin = g_in%c(dir)%hmin
         beta = beta_dh_both(hmin - L,hmin,N,g_in%c(dir)%dhn%f(1))
         call init(a,robertsBoth(hmin-L,hmin,N,beta))
         call process(g,a,dir)
       end subroutine

       ! ******************************************************************** Append

       subroutine con_app_uniform(g,g_in,N,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: g_in
         integer,intent(in) :: N,dir
         type(array) :: a
         real(cp) :: dh
         call check_N(N,'con_app_uniform')
         call init(g,g_in)
         dh = g%c(dir)%dhn_e
         call init(a,uniformRight(g_in%c(dir)%hmax,dh,N))
         call process(g,a,dir)
       end subroutine

       subroutine con_app_Roberts_L(g,g_in,L,N,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: g_in
         real(cp),intent(in) :: L
         integer,intent(in) :: N,dir
         real(cp) :: beta,hmax
         type(array) :: a
         call check_N(N,'con_app_Roberts_L')
         call init(g,g_in)
         hmax = g_in%c(dir)%hmax
         beta = beta_dh_small(hmax,hmax + L,N,g_in%c(dir)%dhn_e)
         call init(a,robertsLeft(hmax,hmax + L,N,beta))
         call process(g,a,dir)
       end subroutine

       subroutine con_app_Roberts_R(g,g_in,L,N,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: g_in
         real(cp),intent(in) :: L
         integer,intent(in) :: N,dir
         real(cp) :: beta,hmax
         type(array) :: a
         call check_N(N,'con_app_Roberts_R')
         call init(g,g_in)
         hmax = g_in%c(dir)%hmax
         beta = beta_dh_small(hmax,hmax + L,N,g_in%c(dir)%dhn%f(1))
         call init(a,robertsRight(hmax,hmax + L,N,beta))
         call process(g,a,dir)
       end subroutine

       subroutine con_app_Roberts_B(g,g_in,L,N,dir)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: g_in
         real(cp),intent(in) :: L
         integer,intent(in) :: N,dir
         real(cp) :: beta,hmax
         type(array) :: a
         call check_N(N,'con_app_Roberts_B')
         call init(g,g_in)
         hmax = g_in%c(dir)%hmax
         beta = beta_dh_both(hmax,hmax + L,N,g_in%c(dir)%dhn_e)
         call init(a,robertsBoth(hmax,hmax + L,N,beta))
         call process(g,a,dir)
       end subroutine

       subroutine check_N(N,caller)
         implicit none
         character(len=*),intent(in) :: caller
         integer,intent(in) :: N
         if (.not.(N.gt.0)) then
           write(*,*) 'Error: N is not > 0 in ',caller,' in extend_grid.f90'
           stop 'Done'
         endif
       end subroutine

       end module