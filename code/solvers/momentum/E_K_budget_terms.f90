       module E_K_budget_terms_mod
       use current_precision_mod
       use mesh_mod
       use SF_mod
       use VF_mod
       use TF_mod
       use dir_tree_mod
       use path_mod
       use string_mod
       use export_raw_processed_mod
       use ops_aux_mod
       use ops_interp_mod
       use ops_discrete_mod
       use ops_norms_mod
       use norms_mod

       implicit none

       private
       public :: Unsteady,           Unsteady_export
       public :: E_K_Convection,     E_K_Convection_export
       public :: E_K_Diffusion,      E_K_Diffusion_export
       public :: E_K_Pressure,       E_K_Pressure_export
       public :: Viscous_Dissipation,Viscous_Dissipation_export
       public :: E_M_Convection,     E_M_Convection_export
       public :: E_M_Tension,        E_M_Tension_export
       public :: Lorentz,            Lorentz_export

       contains

       subroutine Unsteady(e,U,Unm1,dTime,m,VF_CC1,VF_CC2)
         ! Computes: e = 0.5 ∂_t u • u = 0.5 (u_{n+1}^2 - u_{n}^2)/dTime
         implicit none
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: U,Unm1
         real(cp),intent(in) :: dTime
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC1,VF_CC2
         call face2CellCenter(VF_CC1,U   ,m); call square(VF_CC1)
         call face2CellCenter(VF_CC2,Unm1,m); call square(VF_CC2)
         call subtract(VF_CC1,VF_CC2)
         call add(e,VF_CC1)
         call multiply(e,0.5_cp/dTime)
       end subroutine
       subroutine Unsteady_export(e_integral,e,U,Unm1,dTime,m,VF_CC1,VF_CC2,DT)
         implicit none
         real(cp),intent(inout) :: e_integral
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: U,Unm1
         real(cp),intent(in) :: dTime
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC1,VF_CC2
         type(dir_tree),intent(in) :: DT
         call Unsteady(e,U,Unm1,dTime,m,VF_CC1,VF_CC2)
         call export_raw      (m,e,str(DT%e_budget_C),'U_Unsteady',0)
         call export_processed(m,e,str(DT%e_budget_N),'U_Unsteady',1)
         call Ln(e_integral,e,1.0_cp,m)
       end subroutine

       subroutine E_K_Convection(e,U,U_CC,m,VF_F1,VF_F2,VF_CC,SF_CC)
         ! Computes: e = 0.5 (u • ∇) (u • u)
         implicit none
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: U,U_CC
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_F1,VF_F2,VF_CC
         type(SF),intent(inout) :: SF_CC
         write(*,*) 'max(U_CC) = ',maxabs(U_CC)
         call dot(SF_CC,U_CC,U_CC,VF_CC)
         write(*,*) 'max(SF_CC) = ',maxabs(SF_CC)
         call grad(VF_F1,SF_CC,m)
         write(*,*) 'max(VF_F1) = ',maxabs(VF_F1)
         call multiply(VF_F2,VF_F1,U)
         write(*,*) 'max(VF_F2) = ',maxabs(VF_F2)
         call face2CellCenter(VF_CC,VF_F2,m)
         write(*,*) 'max(VF_CC) = ',maxabs(VF_CC)
         call add(e,VF_CC)
         write(*,*) 'max(e) = ',maxabs(e)
         call multiply(e,0.5_cp)
         write(*,*) 'max(e) = ',maxabs(e)
       end subroutine
       subroutine E_K_Convection_export(e_integral,e,U,U_CC,m,VF_F1,VF_F2,VF_CC,SF_CC,DT)
         implicit none
         real(cp),intent(inout) :: e_integral
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: U,U_CC
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_F1,VF_F2,VF_CC
         type(SF),intent(inout) :: SF_CC
         type(dir_tree),intent(in) :: DT
         write(*,*) '-------------------------------------------E_K_Convection_export start'
         write(*,*) 'e_integral = ',e_integral
         call E_K_Convection(e,U,U_CC,m,VF_F1,VF_F2,VF_CC,SF_CC)
         call export_raw      (m,e,str(DT%e_budget_C),'E_K_Convection',0)
         call export_processed(m,e,str(DT%e_budget_N),'E_K_Convection',1)
         call Ln(e_integral,e,1.0_cp,m)
         write(*,*) 'e_integral = ',e_integral
         write(*,*) '-------------------------------------------E_K_Convection_export end'
       end subroutine

       subroutine E_K_Diffusion(e,U_CC,m,VF_CC)
         ! Computes: e = 0.5 ∇² (u • u)
         implicit none
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: U_CC
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC
         call dot(e,U_CC,U_CC,VF_CC)
         call assign(VF_CC%x,e)
         call lap(e,VF_CC%x,m)
         call multiply(e,0.5_cp)
       end subroutine
       subroutine E_K_Diffusion_export(e_integral,e,U_CC,m,VF_CC,DT)
         implicit none
         real(cp),intent(inout) :: e_integral
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: U_CC
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC
         type(dir_tree),intent(in) :: DT
         call E_K_Diffusion(e,U_CC,m,VF_CC)
         call export_raw      (m,e,str(DT%e_budget_C),'E_K_Diffusion',0)
         call export_processed(m,e,str(DT%e_budget_N),'E_K_Diffusion',1)
         call Ln(e_integral,e,1.0_cp,m)
       end subroutine

       subroutine E_K_Pressure(e,U,p,m,VF_F)
         ! Computes: e = ∇•(pu)
         implicit none
         type(SF),intent(inout) :: e
         type(SF),intent(in) :: p
         type(VF),intent(in) :: U
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_F
         call cellCenter2Face(VF_F,p,m)
         call multiply(VF_F,U)
         call div(e,VF_F,m)
       end subroutine
       subroutine E_K_Pressure_export(e_integral,e,U,p,m,VF_F,DT)
         implicit none
         real(cp),intent(inout) :: e_integral
         type(SF),intent(inout) :: e
         type(SF),intent(in) :: p
         type(VF),intent(in) :: U
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_F
         type(dir_tree),intent(in) :: DT
         call E_K_pressure(e,U,p,m,VF_F)
         call export_raw      (m,e,str(DT%e_budget_C),'E_K_Pressure',0)
         call export_processed(m,e,str(DT%e_budget_N),'E_K_Pressure',1)
         call Ln(e_integral,e,1.0_cp,m)
       end subroutine

       subroutine Viscous_Dissipation(e,U_CC,m,TF_CC1,TF_CC2)
         ! Computes: e = ∇u • ∇u = ∂_i u_j ∂_j u_i = ∂_i u_x ∂_x u_i + 
         !                                             ∂_i u_y ∂_y u_i + 
         !                                             ∂_i u_z ∂_z u_i
         implicit none
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: U_CC
         type(mesh),intent(in) :: m
         type(TF),intent(inout) :: TF_CC1,TF_CC2
         call grad(TF_CC1,U_CC,m)
         call transpose(TF_CC2,TF_CC1)
         call multiply( TF_CC2,TF_CC1)
         call add(TF_CC1%x%x,TF_CC2%x)
         call add(TF_CC1%x%y,TF_CC2%y)
         call add(TF_CC1%x%z,TF_CC2%z)
         call add(e,TF_CC1%x)
       end subroutine
       subroutine Viscous_Dissipation_export(e_integral,e,U_CC,m,TF_CC1,TF_CC2,DT)
         implicit none
         real(cp),intent(inout) :: e_integral
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: U_CC
         type(mesh),intent(in) :: m
         type(TF),intent(inout) :: TF_CC1,TF_CC2
         type(dir_tree),intent(in) :: DT
         call Viscous_Dissipation(e,U_CC,m,TF_CC1,TF_CC2)
         call export_raw      (m,e,str(DT%e_budget_C),'Viscous_Dissipation',0)
         call export_processed(m,e,str(DT%e_budget_N),'Viscous_Dissipation',1)
         call Ln(e_integral,e,1.0_cp,m)
       end subroutine

       subroutine E_M_Convection(e,B,U,m,VF_CC1,VF_CC2,VF_F)
         ! Computes: e = 0.5 (u•∇) (B•B)
         implicit none
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: B,U
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC1,VF_CC2,VF_F
         call face2CellCenter(VF_CC2,B,m)
         write(*,*) 'max(VF_CC2) = ',maxabs(VF_CC2)
         call dot(e,VF_CC2,VF_CC2,VF_CC1)
         write(*,*) 'max(e) = ',maxabs(e)
         call grad(VF_F,e,m)
         write(*,*) 'max(VF_F) = ',maxabs(VF_F)
         call multiply(VF_F,U)
         write(*,*) 'max(VF_F) = ',maxabs(VF_F)
         call face2CellCenter(VF_CC1,VF_F,m)
         write(*,*) 'max(VF_CC1) = ',maxabs(VF_CC1)
         call add(e,VF_CC1)
         write(*,*) 'max(e) = ',maxabs(e)
         call multiply(e,0.5_cp)
         write(*,*) 'max(e) = ',maxabs(e)
       end subroutine
       subroutine E_M_Convection_export(e_integral,e,B,U,m,VF_CC1,VF_CC2,VF_F,DT)
         implicit none
         real(cp),intent(inout) :: e_integral
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: B,U
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC1,VF_CC2,VF_F
         type(dir_tree),intent(in) :: DT
         write(*,*) '-------------------------------------------E_M_Convection_export start'
         call E_M_Convection(e,B,U,m,VF_CC1,VF_CC2,VF_F)
         call export_raw      (m,e,str(DT%e_budget_C),'E_M_Convection',0)
         call export_processed(m,e,str(DT%e_budget_N),'E_M_Convection',1)
         write(*,*) 'max(e) = ',maxabs(e)
         call Ln(e_integral,e,1.0_cp,m)
         write(*,*) 'e_integral = ',e_integral
         write(*,*) '-------------------------------------------E_M_Convection_export end'
       end subroutine

       subroutine E_M_Tension(e,B,U_CC,m,VF_CC1,VF_CC2,VF_CC3,TF_CC)
         ! Computes: e = u•(B•(∇B)) = u_j (B_i (∂_j B_i))
         implicit none
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: B,U_CC
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC1,VF_CC2,VF_CC3
         type(TF),intent(inout) :: TF_CC
         call face2CellCenter(VF_CC2,B,m)
         call grad(TF_CC,VF_CC2,m)
         call dot(VF_CC1%x,TF_CC%x,VF_CC2,VF_CC3)
         call dot(VF_CC1%y,TF_CC%y,VF_CC2,VF_CC3)
         call dot(VF_CC1%z,TF_CC%z,VF_CC2,VF_CC3)
         call multiply(VF_CC1,U_CC)
         call add(e,VF_CC1)
       end subroutine
       subroutine E_M_Tension_export(e_integral,e,B,U_CC,m,VF_CC1,VF_CC2,VF_CC3,TF_CC,DT)
         implicit none
         real(cp),intent(inout) :: e_integral
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: B,U_CC
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC1,VF_CC2,VF_CC3
         type(TF),intent(inout) :: TF_CC
         type(dir_tree),intent(in) :: DT
         call E_M_Tension(e,B,U_CC,m,VF_CC1,VF_CC2,VF_CC3,TF_CC)
         call export_raw      (m,e,str(DT%e_budget_C),'E_M_Tension',0)
         call export_processed(m,e,str(DT%e_budget_N),'E_M_Tension',1)
         call Ln(e_integral,e,1.0_cp,m)
       end subroutine

       subroutine Lorentz(e,J,B,U_CC,m,VF_CC1,VF_CC2,VF_CC3,VF_F)
         ! Computes: e = u•(jxB)
         implicit none
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: J,B,U_CC
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC1,VF_CC2,VF_CC3,VF_F
         call edge2CellCenter(VF_CC1,J,m,VF_F)
         call face2CellCenter(VF_CC2,B,m)
         call cross(VF_CC3,VF_CC1,VF_CC2)
         call multiply(VF_CC3,U_CC)
         call add(e,VF_CC3)
       end subroutine
       subroutine Lorentz_export(e_integral,e,J,B,U_CC,m,VF_CC1,VF_CC2,VF_CC3,VF_F,DT)
         implicit none
         real(cp),intent(inout) :: e_integral
         type(SF),intent(inout) :: e
         type(VF),intent(in) :: J,B,U_CC
         type(mesh),intent(in) :: m
         type(VF),intent(inout) :: VF_CC1,VF_CC2,VF_CC3,VF_F
         type(dir_tree),intent(in) :: DT
         call Lorentz(e,J,B,U_CC,m,VF_CC1,VF_CC2,VF_CC3,VF_F)
         call export_raw      (m,e,str(DT%e_budget_C),'Lorentz',0)
         call export_processed(m,e,str(DT%e_budget_N),'Lorentz',1)
         call Ln(e_integral,e,1.0_cp,m)
       end subroutine

       end module