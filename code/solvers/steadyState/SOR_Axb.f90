      module SOR_mod
      ! call SORSolver(SOR,u,f,u_bcs,g,ss,norm,displayTF)
      ! solves the poisson equation:
      !     A u = f
      ! for a given f, boundary conditions for u (u_bcs), grid (g)
      ! and solver settings (ss) using the iterative Successive Over 
      ! Realxation (SOR) method
      ! 
      ! Note that the variant of Gauss-Seidel/SOR called
      ! "red-black" Gauss-Seidel is used.
      !
      ! Input:
      !     u            = initial guess for u
      !     f            = RHS of above equation
      !     u_bcs        = boundary conditions for u. Refer to BCs_mod for more info.
      !     g            = contains grid information (dhc,dhn)
      !     ss           = solver settings (specifies max iterations, tolerance etc.)
      !     norm         = Ln norms of residual
      !     displayTF    = print residuals to screen (T,F)
      ! 
      ! Flags: (_PARALLELIZE_SOR_,
      !         _EXPORT_SOR_CONVERGENCE_)

      use grid_mod
      use applyBCs_mod
      use BCs_mod
      use norms_mod
      use ops_discrete_mod
      use ops_aux_mod
      use SF_mod
      use VF_mod

      use solverSettings_mod
#ifdef _EXPORT_SOR_CONVERGENCE_
      use IO_tools_mod
#endif
      implicit none

      private
      public :: SORSolver,solve
      public :: init,delete

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif
       real(cp),parameter :: PI = 3.14159265358979_cp

      logical, parameter :: useGaussSeidel = .true.

      type SORSolver
        character(len=5) :: name
        type(grid) :: p,d ! Primary / Dual grids
        type(SF) :: Au,res,r ! laplacian, residual, coefficient
        real(cp) :: omega
        integer,dimension(3) :: gt,s
        logical :: setCoeff
      end type
      
      interface init;        module procedure initSOR;       end interface
      interface delete;      module procedure deleteSOR;     end interface
      interface solve;       module procedure solveSOR;      end interface

      interface init_r;      module procedure init_r_RF;     end interface
      interface init_r;      module procedure init_r_SF;     end interface

      contains

      subroutine initSOR(SOR,s,g)
        implicit none
        type(SORSolver),intent(inout) :: SOR
        integer,dimension(3),intent(in) :: s
        type(grid),intent(in) :: g
        integer :: Nx,Ny,Nz,i
        
        SOR%s = s

        do i=1,3
          if (SOR%s(i).eq.g%c(i)%sc) then
            call init(SOR%p,g%c(i)%hc,i,2) ! grid made from cc --> p%dhn is dhc
            call init(SOR%d,g%c(i)%hn,i,2) ! grid made from n --> d%dhn is dhn
            SOR%gt(i) = 1
          elseif(SOR%s(i).eq.g%c(i)%sn) then
            call init(SOR%p,g%c(i)%hn,i,2) ! grid made from n --> p%dhn is dhn
            call init(SOR%d,g%c(i)%hc,i,2) ! grid made from cc --> d%dhn is dhc
            SOR%gt(i) = 0
          else
            write(*,*) 's = ',SOR%s
            write(*,*) 'sc = ',(/g%c(1)%sc,g%c(2)%sc,g%c(3)%sc/)
            write(*,*) 'sn = ',(/g%c(1)%sn,g%c(2)%sn,g%c(3)%sn/)
            stop 'Error: grid type was not determined in SOR.f90'
          endif
        enddo

        call init(SOR%Au,SOR%s)
        call init(SOR%res,SOR%s)
        call init(SOR%r,SOR%s)
        call init_r(SOR%r,SOR%p%c(1)%dhn,SOR%p%c(2)%dhn,SOR%p%c(3)%dhn,&
        SOR%d%c(1)%dhn,SOR%d%c(2)%dhn,SOR%d%c(3)%dhn,SOR%gt)

        if (useGaussSeidel) then
          SOR%omega = 1.0_cp
          SOR%name = 'GS '
        else
          Nx = s(1); Ny = s(2); Nz = s(3)
          SOR%omega = 2.0_cp/(1.0_cp + sqrt(1.0_cp - & 
           ((cos(PI/real(Nx+1,cp)) + cos(PI/real(Ny+1,cp)) + &
             cos(PI/real(Nz+1,cp)))/3.0_cp)**2.0_cp))
          SOR%name = 'SOR'
        endif
      end subroutine

      subroutine deleteSOR(SOR)
        implicit none
        type(SORSolver),intent(inout) :: SOR
        call delete(SOR%p)
        call delete(SOR%d)
        call delete(SOR%Au)
        call delete(SOR%res)
        call delete(SOR%r)

        ! write(*,*) 'SOR object deleted'
      end subroutine


      subroutine solveSOR(SOR,u,f,g,ss,norm,displayTF)
        implicit none
        type(SORSolver),intent(inout) :: SOR
        type(SF),intent(inout) :: u
        type(SF),intent(in) :: f
        type(grid),intent(in) :: g
        type(solverSettings),intent(inout) :: ss
        type(norms),intent(inout) :: norm
        logical,intent(in) :: displayTF
        ! Locals
        integer :: ijk
        logical :: TF,continueLoop
        integer :: maxIterations
#ifdef _EXPORT_SOR_CONVERGENCE_
        integer :: NU
#endif
        
        ! call init(SOR,shape(f),g)

        call solverSettingsSet(ss)
        ijk = 0

        ! Boundaries
        call applyAllBCs(u,g) ! Necessary with ghost nodes

        if (getMaxIterationsTF(ss)) then
          maxIterations = getMaxIterations(ss)
          TF = (maxIterations.ge.1)
        else; TF = .true.
        endif
        continueLoop = .true.

#ifdef _EXPORT_SOR_CONVERGENCE_
        NU = newAndOpen('out\','norm_SOR')
#endif

        do while (continueLoop.and.TF)
          ijk = ijk + 1

          ! THE ORDER OF THESE ROUTINE CALLS IS IMPORTANT. DO NOT CHANGE.

#ifdef _PARALLELIZE_SOR_
          !$OMP PARALLEL

#endif

          call innerLoop(u,f,SOR%r,SOR,(/0,0,0/)) ! Even in odd plane

          call innerLoop(u,f,SOR%r,SOR,(/1,0,0/)) ! Even in even plane
          call innerLoop(u,f,SOR%r,SOR,(/0,1,0/)) ! Even in even plane
          call innerLoop(u,f,SOR%r,SOR,(/0,0,1/)) ! Even in even plane


#ifdef _PARALLELIZE_SOR_
          !$OMP END PARALLEL
          !$OMP PARALLEL

#endif

          call innerLoop(u,f,SOR%r,SOR,(/1,1,1/)) ! Odd in odd plane

          call innerLoop(u,f,SOR%r,SOR,(/0,1,1/)) ! Odd in even plane
          call innerLoop(u,f,SOR%r,SOR,(/1,0,1/)) ! Odd in even plane
          call innerLoop(u,f,SOR%r,SOR,(/1,1,0/)) ! Odd in even plane

#ifdef _PARALLELIZE_SOR_
          !$OMP END PARALLEL

#endif

          call applyAllBCs(u,g)

          if (getMinToleranceTF(ss)) then
            call lap(SOR%Au,u,g)
            call subtract(SOR%res,SOR%Au,f)
            call zeroGhostPoints(SOR%res)
            call compute(norm,SOR%res,g)
            call setTolerance(ss,norm%L2)
          endif

#ifdef _EXPORT_SOR_CONVERGENCE_
            call lap(SOR%Au,u,g)
            call subtract(SOR%res,SOR%Au,f)
            call zeroGhostPoints(SOR%res)
            call compute(norm,SOR%res,g)
            write(NU,*) norm%L1,norm%L2,norm%Linf
#endif

          call setIteration(ss,ijk)

          ! ********************************* CHECK TO EXIT ************************************
          call checkCondition(ss,continueLoop)
          if (.not.continueLoop) exit
          ! ************************************************************************************
        enddo

#ifdef _EXPORT_SOR_CONVERGENCE_
        close(NU)
#endif
        
        ! Subtract mean (for Pressure Poisson)
        ! Okay for SOR alone when comparing with u_exact, but not okay for MG
        ! This step is not necessary if mean(f) = 0 and all BCs are Neumann.
        if (getAllNeumann(u%RF(1)%b)) then
          call subtract(u,mean(u))
        endif

        if (displayTF) then
          write(*,*) 'SOR parameter = ',SOR%omega
          write(*,*) '(Final,max) '//SOR%name//' iteration = ',ijk,maxIterations

          call lap(SOR%Au,u,g)
          call subtract(SOR%res,SOR%Au,f)
          call zeroGhostPoints(SOR%res)
          call compute(norm,SOR%res,g)
          call print(norm,SOR%name//' Residuals for '//trim(adjustl(getName(ss))))
        endif

        ! call delete(SOR)
      end subroutine

      subroutine innerLoop(u,f,r,SOR,odd)
        implicit none
        type(SF),intent(inout) :: u
        type(SF),intent(in) :: f,r
        type(SORSolver),intent(in) :: SOR
        integer,dimension(3),intent(in) :: odd
        integer :: i
        do i=1,u%s
          call redBlack(u%RF(i)%f,f%RF(i)%f,r%RF(i)%f,u%RF(i)%s,&
          SOR%p%c(1)%dhn,SOR%p%c(2)%dhn,SOR%p%c(3)%dhn,&
          SOR%d%c(1)%dhn,SOR%d%c(2)%dhn,SOR%d%c(3)%dhn,&
          SOR%omega,SOR%gt,odd)
        enddo
      end subroutine

      subroutine redBlack(u,f,r,s,dxp,dyp,dzp,dxd,dyd,dzd,omega,gt,odd)
        implicit none
        real(cp),dimension(:,:,:),intent(inout) :: u
        real(cp),dimension(:,:,:),intent(in) :: f,r
        integer,dimension(3) :: s,odd
        real(cp),dimension(:),intent(in) :: dxp,dyp,dzp,dxd,dyd,dzd
        real(cp),intent(in) :: omega
        integer,dimension(3),intent(in) :: gt
        integer :: i,j,k

#ifdef _PARALLELIZE_SOR_
        !$OMP DO

#endif

        do k=2+odd(3),s(3)-1,2
          do j=2+odd(2),s(2)-1,2
            do i=2+odd(1),s(1)-1,2

              u(i,j,k) = u(i,j,k)*(1.0_cp-omega) + &
                 omega*( u(i-1,j,k)/(dxp(i-1) * dxd(i-1+gt(1))) + &
                         u(i+1,j,k)/(dxp( i ) * dxd(i-1+gt(1))) + &
                         u(i,j-1,k)/(dyp(j-1) * dyd(j-1+gt(2))) + &
                         u(i,j+1,k)/(dyp( j ) * dyd(j-1+gt(2))) + &
                         u(i,j,k-1)/(dzp(k-1) * dzd(k-1+gt(3))) + &
                         u(i,j,k+1)/(dzp( k ) * dzd(k-1+gt(3))) &
                       - f(i,j,k) )/r(i,j,k)

            enddo
          enddo
        enddo

#ifdef _PARALLELIZE_SOR_
        !$OMP END DO

#endif
      end subroutine

      subroutine init_r_SF(r,dxp,dyp,dzp,dxd,dyd,dzd,gt)
        implicit none
        type(SF),intent(inout) :: r
        real(cp),dimension(:),intent(in) :: dxp,dyp,dzp,dxd,dyd,dzd
        integer,dimension(3),intent(in) :: gt
        integer :: i
        do i=1,r%s
          call init_r(r%RF(i)%f,r%RF(i)%s,dxp,dyp,dzp,dxd,dyd,dzd,gt)
        enddo
      end subroutine

      subroutine init_r_RF(r,s,dxp,dyp,dzp,dxd,dyd,dzd,gt)
        implicit none
        real(cp),dimension(:,:,:),intent(inout) :: r
        integer,dimension(3) :: s
        real(cp),dimension(:),intent(in) :: dxp,dyp,dzp,dxd,dyd,dzd
        integer,dimension(3),intent(in) :: gt
        integer :: i,j,k

#ifdef _PARALLELIZE_SOR_
        !$OMP DO

#endif

        do k=2,s(3)-1
          do j=2,s(2)-1
            do i=2,s(1)-1
              r(i,j,k) = 1.0_cp/dxd(i-1+gt(1))*(1.0_cp/dxp(i) + 1.0_cp/dxp(i-1)) + & 
                         1.0_cp/dyd(j-1+gt(2))*(1.0_cp/dyp(j) + 1.0_cp/dyp(j-1)) + & 
                         1.0_cp/dzd(k-1+gt(3))*(1.0_cp/dzp(k) + 1.0_cp/dzp(k-1))
            enddo
          enddo
        enddo

#ifdef _PARALLELIZE_SOR_
        !$OMP END DO

#endif
      end subroutine

!       subroutine redBlackSigma(u,f,sigma,s,dxp,dyp,dzp,dxd,dyd,dzd,omega,gt,odd)
!         ! sigx,sigy,sigz are already interpolated to the correct location here
!         implicit none
!         real(cp),dimension(:,:,:),intent(inout) :: u
!         real(cp),dimension(:,:,:),intent(in) :: f
!         type(VF),intent(in) :: sigma
!         integer,dimension(3) :: s,odd
!         real(cp),dimension(:),intent(in) :: dxp,dyp,dzp,dxd,dyd,dzd
!         real(cp),intent(in) :: omega
!         integer,dimension(3),intent(in) :: gt
!         integer :: i,j,k
!         real(cp) :: r

! #ifdef _PARALLELIZE_SOR_
!         !$OMP DO PRIVATE(r)

! #endif

!         do k=2+odd(3),s(3)-1,2
!           do j=2+odd(2),s(2)-1,2
!             do i=2+odd(1),s(1)-1,2
!                 r = 1.0_cp/dxd(i-1+gt(1))*(sigma%x(i,j,k)/dxp(i) + sigma%x(i-1,j,k)/dxp(i-1)) + & 
!                     1.0_cp/dyd(j-1+gt(2))*(sigma%y(i,j,k)/dyp(j) + sigma%y(i,j-1,k)/dyp(j-1)) + & 
!                     1.0_cp/dzd(k-1+gt(3))*(sigma%z(i,j,k)/dzp(k) + sigma%z(i,j,k-1)/dzp(k-1))

!                 u(i,j,k) = u(i,j,k)*(1.0_cp-omega) + &

!                    omega*( u(i-1,j,k)*(sigma%x(i-1,j,k)/(dxp(i-1) * dxd(i-1+gt(1)))) + &
!                            u(i+1,j,k)*(sigma%x(i, j ,k)/(dxp( i ) * dxd(i-1+gt(1)))) + &
!                            u(i,j-1,k)*(sigma%y(i,j-1,k)/(dyp(j-1) * dyd(j-1+gt(2)))) + &
!                            u(i,j+1,k)*(sigma%y(i, j ,k)/(dyp( j ) * dyd(j-1+gt(2)))) + &
!                            u(i,j,k-1)*(sigma%z(i,j,k-1)/(dzp(k-1) * dzd(k-1+gt(3)))) + &
!                            u(i,j,k+1)*(sigma%z(i,j, k )/(dzp( k ) * dzd(k-1+gt(3)))) &
!                          - f(i,j,k) )/r

!             enddo
!           enddo
!         enddo

! #ifdef _PARALLELIZE_SOR_
!         !$OMP END DO

! #endif
!       end subroutine

      end module