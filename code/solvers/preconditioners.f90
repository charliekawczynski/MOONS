      module preconditioners_mod
      use current_precision_mod
      use mesh_mod
      use SF_mod
      use VF_mod
      use ops_aux_mod
      implicit none

      private
      public :: prec_Identity_SF
      public :: prec_Identity_VF
      public :: prec_Lap_SF,diag_Lap_SF
      public :: prec_Lap_VF,diag_Lap_VF
      public :: prec_mom_VF
      public :: prec_ind_VF

      contains

      subroutine prec_Identity_SF(Minv)
        ! Computes Identity preconditioner (no preconditioning)
        !   Minv = I
        implicit none
        type(SF),intent(inout) :: Minv
        call assign(Minv,1.0_cp)
      end subroutine

      subroutine prec_Identity_VF(Minv)
        ! Computes Identity preconditioner (no preconditioning)
        !   Minv = I
        implicit none
        type(VF),intent(inout) :: Minv
        call assign(Minv,1.0_cp)
      end subroutine

      subroutine diag_Lap_SF(diag,m)
        ! Computes Laplacian diagonal: diag = diag( ∇•(∇) )
        implicit none
        type(SF),intent(inout) :: diag
        type(mesh),intent(in) :: m
        integer :: i,j,k,t,pnx,pny,pnz
        integer,dimension(3) :: p
        call assign(diag,0.0_cp)
        p = getPad(diag); pnx = p(1); pny = p(2); pnz = p(3)
        !$OMP PARALLEL DO
        do t=1,m%s; do k=2,diag%RF(t)%s(3)-1; do j=2,diag%RF(t)%s(2)-1; do i=2,diag%RF(t)%s(1)-1
        diag%RF(t)%f(i,j,k) = m%g(t)%c(1)%stagN2CC%D(  i  )*m%g(t)%c(1)%stagCC2N%U( i-1 ) + &
                              m%g(t)%c(1)%stagN2CC%U(i-pnx)*m%g(t)%c(1)%stagCC2N%D(i-pnx) + &
                              m%g(t)%c(2)%stagN2CC%D(  j  )*m%g(t)%c(2)%stagCC2N%U( j-1 ) + &
                              m%g(t)%c(2)%stagN2CC%U(j-pny)*m%g(t)%c(2)%stagCC2N%D(j-pny) + &
                              m%g(t)%c(3)%stagN2CC%D(  k  )*m%g(t)%c(3)%stagCC2N%U( k-1 ) + &
                              m%g(t)%c(3)%stagN2CC%U(k-pnz)*m%g(t)%c(3)%stagCC2N%D(k-pnz)
        enddo; enddo; enddo; enddo
        !$OMP END PARALLEL DO
      end subroutine
      subroutine prec_Lap_SF(Minv,m)
        ! Computes Laplacian diagonal preconditioner, weighted by the cell volume
        !                   1
        !   Minv = --------------------
        !          diag( ∇•(∇) )
        implicit none
        type(SF),intent(inout) :: Minv
        type(mesh),intent(in) :: m
        type(SF) :: vol
        call diag_Lap_SF(Minv,m)
        call init(vol,Minv)
        call volume(vol,m)
        call multiply(Minv,vol)
        call delete(vol)
        call invert(Minv)
        call zeroGhostPoints(Minv)
      end subroutine

      subroutine diag_Lap_VF(diag,m)
        ! Computes Laplacian diagonal: diag = diag( ∇•(∇) )
        implicit none
        type(VF),intent(inout) :: diag
        type(mesh),intent(in) :: m
        call diag_Lap_SF(diag%x,m)
        call diag_Lap_SF(diag%y,m)
        call diag_Lap_SF(diag%z,m)
      end subroutine
      subroutine prec_Lap_VF(Minv,m)
        ! Computes Laplacian diagonal preconditioner, weighted by the cell volume
        ! 
        !                   1
        !   Minv = --------------------
        !          diag( ∇•(∇) )
        implicit none
        type(VF),intent(inout) :: Minv
        type(mesh),intent(in) :: m
        call prec_Lap_SF(Minv%x,m)
        call prec_Lap_SF(Minv%y,m)
        call prec_Lap_SF(Minv%z,m)
      end subroutine

      subroutine prec_mom_SF(Minv,m,c)
        ! Computes Laplacian diagonal preconditioner, weighted by the cell volume
        ! 
        !                   1
        !   Minv = --------------------
        !          diag( I + c∇•(∇) )
        implicit none
        type(SF),intent(inout) :: Minv
        type(mesh),intent(in) :: m
        real(cp),intent(in) :: c
        type(SF) :: vol
        integer :: i,j,k,t,pnx,pny,pnz
        integer,dimension(3) :: p
        call assign(Minv,0.0_cp)
        p = getPad(Minv); pnx = p(1); pny = p(2); pnz = p(3)
        !$OMP PARALLEL DO
        do t=1,m%s; do k=2,Minv%RF(t)%s(3)-1; do j=2,Minv%RF(t)%s(2)-1; do i=2,Minv%RF(t)%s(1)-1
        Minv%RF(t)%f(i,j,k) = m%g(t)%c(1)%stagN2CC%D(  i  )*m%g(t)%c(1)%stagCC2N%U( i-1 ) + &
                              m%g(t)%c(1)%stagN2CC%U(i-pnx)*m%g(t)%c(1)%stagCC2N%D(i-pnx) + &
                              m%g(t)%c(2)%stagN2CC%D(  j  )*m%g(t)%c(2)%stagCC2N%U( j-1 ) + &
                              m%g(t)%c(2)%stagN2CC%U(j-pny)*m%g(t)%c(2)%stagCC2N%D(j-pny) + &
                              m%g(t)%c(3)%stagN2CC%D(  k  )*m%g(t)%c(3)%stagCC2N%U( k-1 ) + &
                              m%g(t)%c(3)%stagN2CC%U(k-pnz)*m%g(t)%c(3)%stagCC2N%D(k-pnz)
        enddo; enddo; enddo; enddo
        !$OMP END PARALLEL DO

        call multiply(Minv,c)
        call add(Minv,1.0_cp)
        call init(vol,Minv)
        call volume(vol,m)
        call multiply(Minv,vol)
        call delete(vol)
        call invert(Minv)
        call zeroGhostPoints(Minv)
      end subroutine

      subroutine prec_mom_VF(Minv,m,c)
        ! Computes Laplacian diagonal preconditioner
        ! 
        !               1
        !   Minv = -----------
        !          diag( I + c∇•(∇) )
        implicit none
        type(VF),intent(inout) :: Minv
        type(mesh),intent(in) :: m
        real(cp),intent(in) :: c
        call prec_mom_SF(Minv%x,m,c)
        call prec_mom_SF(Minv%y,m,c)
        call prec_mom_SF(Minv%z,m,c)
      end subroutine

      subroutine prec_ind_VF(Minv,m,sig,c) ! Verified 1/3/2016
        ! Computes curl-curl diagonal preconditioner
        ! 
        !                     1
        !   Minv = ----------------------
        !          diag( I + c∇x(σ∇x) )
        implicit none
        type(VF),intent(inout) :: Minv
        type(VF),intent(in) :: sig
        type(mesh),intent(in) :: m
        real(cp),intent(in) :: c
        type(VF) :: vol
        integer :: i,j,k,t
        call assign(Minv,0.0_cp)

        !$OMP PARALLEL DO
        do t=1,m%s; do k=2,Minv%x%RF(t)%s(3)-1; do j=2,Minv%x%RF(t)%s(2)-1; do i=2,Minv%x%RF(t)%s(1)-1
        Minv%x%RF(t)%f(i,j,k) = -m%g(t)%c(2)%stagN2CC%D(j)*sig%z%RF(t)%f(i,j, k )*m%g(t)%c(2)%stagCC2N%U(j-1) - & ! i,j-1,k is wrong
                                 m%g(t)%c(2)%stagN2CC%U(j)*sig%z%RF(t)%f(i,j+1,k)*m%g(t)%c(2)%stagCC2N%D( j ) - & ! i,j-1,k is wrong
                                 m%g(t)%c(3)%stagN2CC%D(k)*sig%y%RF(t)%f(i,j, k )*m%g(t)%c(3)%stagCC2N%U(k-1) - &
                                 m%g(t)%c(3)%stagN2CC%U(k)*sig%y%RF(t)%f(i,j,k+1)*m%g(t)%c(3)%stagCC2N%D( k )
        enddo; enddo; enddo; enddo
        !$OMP END PARALLEL DO
        !$OMP PARALLEL DO
        do t=1,m%s; do k=2,Minv%y%RF(t)%s(3)-1; do j=2,Minv%y%RF(t)%s(2)-1; do i=2,Minv%y%RF(t)%s(1)-1
        Minv%y%RF(t)%f(i,j,k) = -m%g(t)%c(1)%stagN2CC%D(i)*sig%z%RF(t)%f(i,j, k )*m%g(t)%c(1)%stagCC2N%U(i-1) - &
                                 m%g(t)%c(1)%stagN2CC%U(i)*sig%z%RF(t)%f(i+1,j,k)*m%g(t)%c(1)%stagCC2N%D( i ) - &
                                 m%g(t)%c(3)%stagN2CC%D(k)*sig%x%RF(t)%f(i,j, k )*m%g(t)%c(3)%stagCC2N%U(k-1) - &
                                 m%g(t)%c(3)%stagN2CC%U(k)*sig%x%RF(t)%f(i,j,k+1)*m%g(t)%c(3)%stagCC2N%D( k )
        enddo; enddo; enddo; enddo
        !$OMP END PARALLEL DO
        !$OMP PARALLEL DO
        do t=1,m%s; do k=2,Minv%z%RF(t)%s(3)-1; do j=2,Minv%z%RF(t)%s(2)-1; do i=2,Minv%z%RF(t)%s(1)-1
        Minv%z%RF(t)%f(i,j,k) = -m%g(t)%c(1)%stagN2CC%D(i)*sig%y%RF(t)%f(i, j ,k)*m%g(t)%c(1)%stagCC2N%U(i-1) - &
                                 m%g(t)%c(1)%stagN2CC%U(i)*sig%y%RF(t)%f(i+1,j,k)*m%g(t)%c(1)%stagCC2N%D( i ) - &
                                 m%g(t)%c(2)%stagN2CC%D(j)*sig%x%RF(t)%f(i, j ,k)*m%g(t)%c(2)%stagCC2N%U(j-1) - &
                                 m%g(t)%c(2)%stagN2CC%U(j)*sig%x%RF(t)%f(i,j+1,k)*m%g(t)%c(2)%stagCC2N%D( j )
        enddo; enddo; enddo; enddo
        !$OMP END PARALLEL DO

        call multiply(Minv,c)
        call add(Minv,1.0_cp)
        call init(vol,Minv)
        call volume(vol,m)
        call multiply(Minv,vol)
        call delete(vol)
        call invert(Minv)
        call zeroGhostPoints(Minv)
      end subroutine

      function getPad(f) result(p)
        implicit none
        type(SF),intent(in) :: f
        integer,dimension(3) :: p
        if (f%is_CC) then;       p(1) = 0; p(2) = 0; p(3) = 0
        elseif (f%is_Node) then; p(1) = 1; p(2) = 1; p(3) = 1
        elseif (f%is_Face) then
          select case (f%face)
          case (1); p(1) = 1; p(2) = 0; p(3) = 0
          case (2); p(1) = 0; p(2) = 1; p(3) = 0
          case (3); p(1) = 0; p(2) = 0; p(3) = 1
          case default; stop 'Error: face must = 1,2,3 in getPad in preconditioners.f90'
          end select
        elseif (f%is_Edge) then
          select case (f%edge)
          case (1); p(1) = 0; p(2) = 1; p(3) = 1
          case (2); p(1) = 1; p(2) = 0; p(3) = 1
          case (3); p(1) = 1; p(2) = 1; p(3) = 0
          case default; stop 'Error: edge must = 1,2,3 in getPad in preconditioners.f90'
          end select
        else; stop 'Error: bad input to getPad in preconditioners.f90'
        endif
      end function

      end module