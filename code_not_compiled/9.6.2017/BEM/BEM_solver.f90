       module BEM_solver_mod
       use current_precision_mod
       use SF_mod
       use VF_mod
       use IO_SF_mod
       use IO_VF_mod
       use dir_tree_mod
       use string_mod
       use path_extend_mod
       use boundary_conditions_mod
       use export_raw_processed_mod
       use ops_embedExtract_mod
       use domain_mod
       use GS_Poisson_mod
       use mesh_extend_mod
       use ops_del_mod
       use ops_aux_mod
       use ops_interp_mod
       use ops_discrete_mod
       use apply_BCs_mod
       use iter_solver_params_mod

       implicit none

       private
       public :: BEM_Poisson

       contains

       subroutine BEM_Poisson(m,DT)
         ! Solves
         !           ∇²x = f = exp(z)
         ! on surface of mesh m
         implicit none
         type(mesh),intent(in) :: m
         type(dir_tree),intent(in) :: DT
         type(domain) :: D_surface
         type(mesh) :: m_surface
         type(VF) :: x,x_surface,f,f_surface
         type(GS_Poisson_SF) :: GS
         integer :: i
         type(iter_solver_params) :: ISP

         call init_surface(m_surface,m)
         call init(D_surface,m_surface,m)

         call init_Face(x,m,0.0_cp)
         call init_Face(f,m,0.0_cp)
         call init_Face(x_surface,m_surface,0.0_cp)
         call init_Face(f_surface,m_surface,0.0_cp)

         call init_BC_mesh(x_surface%x,m_surface) ! MUST COME BEFORE BVAL ASSIGNMENT
         call init_BC_mesh(x_surface%y,m_surface) ! MUST COME BEFORE BVAL ASSIGNMENT
         call init_BC_mesh(x_surface%z,m_surface) ! MUST COME BEFORE BVAL ASSIGNMENT

         do i=1,m_surface%s
           call init_Neumann(x_surface%x%BF(i)%BCs,m%B(i))
           call init_Neumann(x_surface%y%BF(i)%BCs,m%B(i))
           call init_Neumann(x_surface%z%BF(i)%BCs,m%B(i))
           call init(x_surface%x%BF(i)%BCs,0.0_cp)
           call init(x_surface%y%BF(i)%BCs,0.0_cp)
           call init(x_surface%z%BF(i)%BCs,0.0_cp)
         enddo

         ! Changes values on surface from volume
         ! Assign source term:
         call cosineWaves(f%x,m,(/2.0_cp,2.0_cp,2.0_cp/))
         call cosineWaves(f%y,m,(/2.0_cp,2.0_cp,2.0_cp/))
         call cosineWaves(f%z,m,(/2.0_cp,2.0_cp,2.0_cp/))
         call export_raw(m_surface,f_surface,str(DT%BEM),'f_surface',0)

         write(*,*) 'initializing GS'
         call init(ISP,1000,10.0_cp**(-6.0_cp),10.0_cp**(-10.0_cp),100,str(DT%ISP),'BEM')
         call init(GS,x_surface%x,m_surface,ISP,str(DT%BEM),'x_surface%x')
         write(*,*) 'initialized GS'
         write(*,*) 'solving Poisson with GS'
         call solve(GS,x_surface%x,f_surface%x,m_surface,.true.)
         write(*,*) 'solved Poisson with GS'

         call export_raw(m_surface,x_surface,str(DT%BEM),'x_surface',0)

         call delete(GS)
         call delete(D_surface)
         call delete(m_surface)
         call delete(x)
         call delete(x_surface)
         call delete(f)
         call delete(f_surface)
       end subroutine

       end module