       module induction_solver_mod
       ! Constrained Transport (CT) Method reference:
       ! "Tóth, G. The divergence Constraint in Shock-Capturing 
       ! MHD Codes. J. Comput. Phys. 161, 605–652 (2000)."
       use mesh_mod
       use SF_mod
       use VF_mod
       use TF_mod
       use ops_aux_mod
       use ops_interp_mod
       use ops_discrete_mod
       use ops_advect_mod
       use apply_BCs_mod
       use norms_mod
       use AB2_mod
       use GS_Poisson_mod
       use PCG_mod

       implicit none

       private

       ! Explicit time marching methods (CT methods)
       public :: CT_Finite_Rem
       public :: CT_Low_Rem

       ! Implicit time marching methods (diffusion implicit)
       public :: ind_PCG_BE_EE_cleanB_PCG


#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

       contains

       subroutine CT_Finite_Rem(B,B0,U_E,J,sigmaInv_E,m,Rem,dt,temp_F1,temp_F2,temp_E,temp_E_TF)
         ! Solves:
         !             ∂B/∂t = ∇x(ux(B⁰+B)) - Rem⁻¹∇x(σ⁻¹∇xB)
         ! Computes:
         !             B (above)
         !             J = Rem⁻¹∇xB
         ! Method:
         !             Constrained Transport (CT)
         ! Info:
         !             cell face => B,B0
         !             cell edge => J,sigmaInv_E,U_E
         !             Finite Rem
         implicit none
         type(VF),intent(inout) :: B,J,temp_E,temp_F1,temp_F2
         type(VF),intent(in) :: B0,sigmaInv_E
         type(TF),intent(inout) :: temp_E_TF
         type(TF),intent(in) :: U_E
         type(mesh),intent(in) :: m
         real(cp),intent(in) :: dt,Rem
         call add(temp_F2,B,B0) ! Since finite Rem
         call advect_B(temp_F1,U_E,temp_F2,m,temp_E_TF,temp_E)
         call curl(J,B,m)
         call multiply(J,1.0_cp/Rem)
         call multiply(temp_E,J,sigmaInv_E)
         call curl(temp_F2,temp_E,m)
         call subtract(temp_F1,temp_F2)
         call multiply(temp_F1,dt)
         call add(B,temp_F1)
         call apply_BCs(B,m)
       end subroutine

       subroutine CT_Low_Rem(B,B0,U_E,J,sigmaInv_E,m,N_induction,dt,temp_F1,temp_F2,temp_E,temp_E_TF)
         ! Solves:
         !             ∂B/∂t = ∇x(uxB⁰) - ∇x(σ⁻¹∇xB)
         ! Computes:
         !             B (above)
         !             J = ∇xB
         ! Method:
         !             Constrained Transport (CT)
         ! Info:
         !             cell face => B,B0
         !             cell edge => J,sigmaInv,U_E
         !             Finite Rem
         implicit none
         type(VF),intent(inout) :: B,J,temp_E,temp_F1,temp_F2
         type(VF),intent(in) :: B0,sigmaInv_E
         type(TF),intent(inout) :: temp_E_TF
         type(TF),intent(in) :: U_E
         type(mesh),intent(in) :: m
         real(cp),intent(in) :: dt
         integer,intent(in) :: N_induction
         integer :: i
         do i=1,N_induction
           call advect_B(temp_F1,U_E,B0,m,temp_E_TF,temp_E)
           call curl(J,B,m)
           call multiply(temp_E,J,sigmaInv_E)
           call curl(temp_F2,temp_E,m)
           call subtract(temp_F1,temp_F2)
           call multiply(temp_F1,dt)
           call add(B,temp_F1)
           call apply_BCs(B,m)
         enddo
       end subroutine

       subroutine ind_PCG_BE_EE_cleanB_PCG(PCG_B,PCG_cleanB,B,B0,U_E,m,dt,N_induction,&
         N_cleanB,compute_norms,temp_F1,temp_F2,temp_E,temp_E_TF,temp_CC,phi)
         ! Solves:
         !             ∂B/∂t = ∇x(ux(B⁰+B)) - Rem⁻¹∇x(σ⁻¹∇xB)
         ! Computes:
         !             B (above)
         ! Method:
         !             Preconditioned Conjugate Gradient Method (induction equation)
         !             Preconditioned Conjugate Gradient Method (elliptic cleaning procedure)
         ! Info:
         !             cell face => B,B0
         !             cell edge => sigmaInv_E,U_E
         !             Finite Rem
         implicit none
         type(PCG_solver_VF),intent(inout) :: PCG_B
         type(PCG_solver_SF),intent(inout) :: PCG_cleanB
         type(VF),intent(inout) :: B
         type(VF),intent(in) :: B0
         type(TF),intent(in) :: U_E
         type(SF),intent(inout) :: temp_CC,phi
         type(TF),intent(inout) :: temp_E_TF
         type(VF),intent(inout) :: temp_F1,temp_F2,temp_E
         type(mesh),intent(in) :: m
         real(cp),intent(in) :: dt
         integer,intent(in) :: N_induction,N_cleanB
         logical,intent(in) :: compute_norms
         ! Induction
         call add(temp_F2,B,B0) ! Since finite Rem
         call advect_B(temp_F1,U_E,temp_F2,m,temp_E_TF,temp_E)
         call multiply(temp_F1,dt)
         call add(temp_F1,B)
         call solve(PCG_B,B,temp_F1,m,N_induction,compute_norms)
         ! Clean B
         call div(temp_CC,B,m)
         call solve(PCG_cleanB,phi,temp_CC,m,N_cleanB,compute_norms)
         call grad(temp_F1,phi,m)
         call subtract(B,temp_F1)
         call apply_BCs(B,m)
       end subroutine

       end module