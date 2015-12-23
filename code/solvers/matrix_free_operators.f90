      module matrix_free_operators_mod
      ! These matrix-free operators all have the following format:
      !          call operator(Ax,x,vol,m,tempk,MFP,k)
      ! All parameters must be passed, but need not be used, in the
      ! operator. The goal of the MFP object is to allow easy penetration
      ! of parameters needed for any sort of time stepping scheme.
      ! 
      ! NOTES:
      !        x = primary variable being operated on
      !        Ax = result
      !        m = mesh
      !        MFP = matrix-free parameters (contains )
      !        V = cell volume
      !        k,tempk = VF of intermediate location
      !        c = discretization parameter
      !               for example: c_{mom,ind,eng} = (dt/Re,dt/Rem,dt/Pe)

      use mesh_mod
      use ops_discrete_mod
      use ops_aux_mod
      use SF_mod
      use VF_mod
      use ops_interp_mod
      use matrix_free_params_mod
      implicit none

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

      private
      public :: Laplacian_uniform_props
      public :: Laplacian_nonuniform_props
      public :: ind_diffusion
      public :: eng_diffusion
      public :: mom_diffusion

      contains

      subroutine Laplacian_uniform_props(Ax,x,k,vol,m,MFP,tempk)
        ! COMPUTES:
        !        A = ∇•(∇)
        implicit none
        type(SF),intent(inout) :: Ax
        type(SF),intent(in) :: x,vol
        type(VF),intent(in) :: k
        type(mesh),intent(in) :: m
        type(VF),intent(inout) :: tempk
        type(matrix_free_params),intent(in) :: MFP
        logical :: suppress_warning
        suppress_warning = MFP%suppress_warning
        call grad(tempk,x,m)
        call div(Ax,tempk,m)
        call zeroGhostPoints(Ax)
      end subroutine

      subroutine Laplacian_nonuniform_props(Ax,x,k,vol,m,MFP,tempk)
        ! COMPUTES:
        !        A = ∇•(k∇)
        implicit none
        type(SF),intent(inout) :: Ax
        type(SF),intent(in) :: x,vol
        type(VF),intent(in) :: k
        type(mesh),intent(in) :: m
        type(VF),intent(inout) :: tempk
        type(matrix_free_params),intent(in) :: MFP
        logical :: suppress_warning
        suppress_warning = MFP%suppress_warning
        call grad(tempk,x,m)
        call multiply(tempk,k)
        call div(Ax,tempk,m)
        call zeroGhostPoints(Ax)
      end subroutine

      subroutine ind_diffusion(Ax,x,k,vol,m,MFP,tempk)
        ! COMPUTES:
        !        A = {I + c_ind ∇x(k∇x)}
        implicit none
        type(VF),intent(inout) :: Ax
        type(VF),intent(in) :: x,vol
        type(VF),intent(in) :: k
        type(mesh),intent(in) :: m
        type(VF),intent(inout) :: tempk
        type(matrix_free_params),intent(in) :: MFP
        call curl(tempk,x,m)
        call multiply(tempk,k)
        call curl(Ax,tempk,m)
        call multiply(Ax,MFP%c_ind)
        call add(Ax,x)
        call zeroGhostPoints(Ax)
      end subroutine

      subroutine eng_diffusion(Ax,x,k,vol,m,MFP,tempk)
        ! Computes:
        !        A = {I + c_eng ∇•(k∇)}
        implicit none
        type(SF),intent(inout) :: Ax
        type(SF),intent(in) :: x,vol
        type(VF),intent(in) :: k
        type(mesh),intent(in) :: m
        type(matrix_free_params),intent(in) :: MFP
        type(VF),intent(inout) :: tempk
        call grad(tempk,x,m)
        call multiply(tempk,k)
        call div(Ax,tempk,m)
        call multiply(Ax,MFP%c_eng)
        call add(Ax,x)
        call zeroGhostPoints(Ax)
      end subroutine

      subroutine mom_diffusion(Ax,x,k,vol,m,MFP,tempk)
        ! Computes:
        !        A = {I + c_mom ∇•(k∇)}
        implicit none
        type(VF),intent(inout) :: Ax
        type(VF),intent(in) :: x,vol
        type(VF),intent(in) :: k
        type(mesh),intent(in) :: m
        type(matrix_free_params),intent(in) :: MFP
        type(VF),intent(inout) :: tempk
        call lap_centered(Ax,x,m,tempk)
        call multiply(Ax,MFP%c_mom)
        call add(Ax,x)
        call zeroGhostPoints(Ax)
      end subroutine

      end module