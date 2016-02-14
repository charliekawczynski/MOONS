       module apply_BCs_edges_mod
       ! Notes:
       !       o Edge BCs ARE NOT USED FOR PERIODIC BCs. It was decided that
       !         periodic BCs are typically used for simple geometries, not to
       !         mention they would only be applicable across 1 grid (and not 1 mesh)
       !       o Edge BCs defines BCs at a grid's edge. This is necessary
       !         because edge BCs will not be defined if two adjoining 
       !         face-stitching occurs. 
       !       o For example, velocty is enforced 
       !         at an edge in the below diagram, where the top right block 
       !         skips face BCs on the left and bottom sides
       ! 
       !          --------------
       !                       |
       !          --------     |
       !                /|     |
       !               / |     |
       !              /  |     |
       !             /
       !           Here
       ! 
       !       o Data locations that are potentially defined (depending on 
       !         Dirichlet/Nuemann BCs) are illustrated below with asterisks
       ! 
       !        |       |       |     
       !        |       |       |     
       !         ------- ------- -----
       !        |       |       |     
       !        |       |       |     
       !        |       |       |     
       !        *---*---*------- -----
       !        |       |       |     
       !        |   *   *       |     
       !        |       |       |     
       !         -------*------- -----
       ! 
       !       o Edge data is separated into 3 (edge) directions. This is 
       !         listed and illustrated below
       !         Edges are organized as follows
       !                minmin(i)
       !                minmax(i)
       !                maxmin(i)
       !                maxmax(i)
       !         for direction i, covering all 12 edge.
       !         
       !         To be more explicit:
       !         
       !         x:  (i=1)   minmin(1):  ymin,zmin ! Right hand rule
       !                     minmax(2):  ymin,zmax ! Right hand rule
       !                     maxmin(3):  ymax,zmin ! Right hand rule
       !                     maxmax(4):  ymax,zmax ! Right hand rule
       !         
       !         y:  (i=2)   minmin(5):  xmin,zmin ! LEFT hand rule
       !                     minmax(6):  xmin,zmax ! LEFT hand rule
       !                     maxmin(7):  xmax,zmin ! LEFT hand rule
       !                     maxmax(8):  xmax,zmax ! LEFT hand rule
       !         
       !         z:  (i=3)   minmin(9):  xmin,ymin ! Right hand rule
       !                     minmax(10): xmin,ymax ! Right hand rule
       !                     maxmin(11): xmax,ymin ! Right hand rule
       !                     maxmax(12): xmax,ymax ! Right hand rule
       ! 
       !          d2
       !          ^
       !          |
       !          -------------------
       ! minmax   |   |         |   | maxmax
       !          |---|---------|---|
       !          |   |         |   |
       !          |   |         |   |
       !          |   |         |   |
       !          |---|---------|---|
       ! minmin   |   |         |   | maxmin
       !          ---------------------->d1
       ! 
       ! 
       use RF_mod
       use SF_mod
       use VF_mod
       use bctype_mod
       use BCs_mod
       use grid_mod
       use mesh_mod
       implicit none

       private
       public :: apply_BCs_edges

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif


       interface apply_BCs_edges;       module procedure apply_BCs_edges_VF;     end interface
       interface apply_BCs_edges;       module procedure apply_BCs_edges_SF;     end interface

       contains

       subroutine apply_BCs_edges_VF(U,m)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         call apply_BCs_edges(U%x,m)
         call apply_BCs_edges(U%y,m)
         call apply_BCs_edges(U%z,m)
       end subroutine

       subroutine apply_BCs_edges_SF(U,m)
         implicit none
         type(SF),intent(inout) :: U
         type(mesh),intent(in) :: m
         if (m%s.gt.1) call apply_edge_SF(U,m)
       end subroutine


       subroutine apply_edge_SF(U,m,dir,d1,d2,e)
         implicit none
         type(SF),intent(inout) :: U
         type(mesh),intent(in) :: m
         integer,intent(in) :: dir,d1,d2
         integer,dimension(4),intent(in) :: e
         integer :: i
         integer,dimension(2) :: a,fd
         logical :: CCd1,CCd2
         logical,dimension(4) :: TF
         logical,dimension(2) :: TF_prep
         CCd1 = CC_along(U,d1)
         CCd2 = CC_along(U,d2)
         if (m%s.gt.1) then; do i=1,m%s
           ! Conditions to apply edges (ALL must be true): 
           ! 1) At least 1 adjacent face must be Dirichlet
           ! 2) The Dirichlet face must not be stitched
           ! 3) The other adjacent face cannot be Periodic

           a = adjacent_faces(e(1))
           fd(1) = direction_from_face(a(1)); fd(2) = direction_from_face(a(2))
           if (is_min(a(1))) then;
                 TF_prep(1) = U%RF(i)%b%f(a(1))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmin(fd(1)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(1))%b%Periodic))
           else; TF_prep(1) = U%RF(i)%b%f(a(1))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmax(fd(1)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(1))%b%Periodic))
           endif
           if (is_min(a(2))) then;
                 TF_prep(2) = U%RF(i)%b%f(a(2))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmin(fd(2)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(2))%b%Periodic))
           else; TF_prep(2) = U%RF(i)%b%f(a(2))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmax(fd(2)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(2))%b%Periodic))
           endif
           TF(1) = all(TF_prep)

           a = adjacent_faces(e(2))
           fd(1) = direction_from_face(a(1)); fd(2) = direction_from_face(a(2))
           if (is_min(a(1))) then;
                 TF_prep(1) = U%RF(i)%b%f(a(1))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmin(fd(1)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(1))%b%Periodic))
           else; TF_prep(1) = U%RF(i)%b%f(a(1))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmax(fd(1)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(1))%b%Periodic))
           endif
           if (is_min(a(2))) then;
                 TF_prep(2) = U%RF(i)%b%f(a(2))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmin(fd(2)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(2))%b%Periodic))
           else; TF_prep(2) = U%RF(i)%b%f(a(2))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmax(fd(2)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(2))%b%Periodic))
           endif
           TF(2) = all(TF_prep)

           a = adjacent_faces(e(3))
           fd(1) = direction_from_face(a(1)); fd(2) = direction_from_face(a(2))
           if (is_min(a(1))) then;
                 TF_prep(1) = U%RF(i)%b%f(a(1))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmin(fd(1)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(1))%b%Periodic))
           else; TF_prep(1) = U%RF(i)%b%f(a(1))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmax(fd(1)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(1))%b%Periodic))
           endif
           if (is_min(a(2))) then;
                 TF_prep(2) = U%RF(i)%b%f(a(2))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmin(fd(2)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(2))%b%Periodic))
           else; TF_prep(2) = U%RF(i)%b%f(a(2))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmax(fd(2)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(2))%b%Periodic))
           endif
           TF(3) = all(TF_prep)

           a = adjacent_faces(e(4))
           fd(1) = direction_from_face(a(1)); fd(2) = direction_from_face(a(2))
           if (is_min(a(1))) then;
                 TF_prep(1) = U%RF(i)%b%f(a(1))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmin(fd(1)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(1))%b%Periodic))
           else; TF_prep(1) = U%RF(i)%b%f(a(1))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmax(fd(1)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(1))%b%Periodic))
           endif
           if (is_min(a(2))) then;
                 TF_prep(2) = U%RF(i)%b%f(a(2))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmin(fd(2)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(2))%b%Periodic))
           else; TF_prep(2) = U%RF(i)%b%f(a(2))%b%Dirichlet.and.(.not.m%g(i)%st_face%hmax(fd(2)))&
                                                           .and.(.not.(U%RF(i)%b%f(a(2))%b%Periodic))
           endif
           TF(4) = all(TF_prep)

           if (TF(1)) call app_minmin(U%RF(i),m%g(i),e(1),d1,d2,CCd1,CCd2,dir) ! minmin
           if (TF(2)) call app_minmax(U%RF(i),m%g(i),e(2),d1,d2,CCd1,CCd2,dir) ! minmax
           if (TF(3)) call app_maxmin(U%RF(i),m%g(i),e(3),d1,d2,CCd1,CCd2,dir) ! maxmin
           if (TF(4)) call app_maxmax(U%RF(i),m%g(i),e(4),d1,d2,CCd1,CCd2,dir) ! maxmax
         enddo; endif
       end subroutine

       function stitch_TF(RF,g,d,f,TFd1_min,TFd2_min) result(TF)
         !        z                      x                      y                   
         !        ^  6                   ^  2                   ^  4                
         !        2-----4                2-----4                2-----4             
         !        |     |     dir = 1    |     |     dir = 2    |     |     dir = 3
         !       3|     |4              5|     |6              1|     |2            
         !        |     |                |     |                |     |             
         !        1-----3-> y            1-----3-> z            1-----3-> x         
         !           5                      1                      3
         implicit none
         type(realField),intent(inout) :: RF
         type(grid),intent(in) :: g
         integer,dimension(2),intent(in) :: d,f
         logical,intent(in) :: TFd1_min,TFd2_min
         logical,dimension(2) :: TF_prep
         logical :: TF
         if (TFd1_min) then; TF_prep(1) = RF%b%f(f(1))%b%Dirichlet.and.(.not.g%st_face%hmin(d(1)))
         else;               TF_prep(1) = RF%b%f(f(1))%b%Dirichlet.and.(.not.g%st_face%hmax(d(1)))
         endif
         if (TFd2_min) then; TF_prep(2) = RF%b%f(f(2))%b%Dirichlet.and.(.not.g%st_face%hmin(d(2)))
         else;               TF_prep(2) = RF%b%f(f(2))%b%Dirichlet.and.(.not.g%st_face%hmax(d(2)))
         endif
         TF = all(TF_prep)
       end function

       subroutine apply_edges_SF(U,m,dir,d1,d2,e)
         implicit none
         type(SF),intent(inout) :: U
         type(mesh),intent(in) :: m
         integer,intent(in) :: dir
         integer,dimension(4),intent(in) :: e
         integer,dimension(2),intent(in) :: a
         integer :: i
         logical,dimension(4) :: TF
         if (U%is_CC) then
         do i=1,m%s; do k = 1,3
         e = edges_given_dir(k); a = adjacent_directions(k)
         select case (k)
         case (1); TF(1) = stitch_TF(U%RF(i),m%g(i),(/2,3/),(/3,5/),.true.,.true.)
                   TF(2) = stitch_TF(U%RF(i),m%g(i),(/2,3/),(/3,6/),.true.,.false.)
                   TF(3) = stitch_TF(U%RF(i),m%g(i),(/2,3/),(/4,5/),.false.,.true.)
                   TF(4) = stitch_TF(U%RF(i),m%g(i),(/2,3/),(/4,6/),.false.,.false.)
         case (2); TF(1) = stitch_TF(U%RF(i),m%g(i),(/3,1/),(/5,1/),.true.,.true.)
                   TF(2) = stitch_TF(U%RF(i),m%g(i),(/3,1/),(/5,2/),.true.,.false.)
                   TF(3) = stitch_TF(U%RF(i),m%g(i),(/3,1/),(/6,1/),.false.,.true.)
                   TF(4) = stitch_TF(U%RF(i),m%g(i),(/3,1/),(/6,2/),.false.,.false.)
         case (3); TF(1) = stitch_TF(U%RF(i),m%g(i),(/1,2/),(/1,3/),.true.,.true.)
                   TF(2) = stitch_TF(U%RF(i),m%g(i),(/1,2/),(/1,4/),.true.,.false.)
                   TF(3) = stitch_TF(U%RF(i),m%g(i),(/1,2/),(/2,3/),.false.,.true.)
                   TF(4) = stitch_TF(U%RF(i),m%g(i),(/1,2/),(/2,4/),.false.,.false.)
         case default; stop 'Error: dir must = 1,2,3 in apply_edges_SF'
         end select
         if (TF(1)) call a_CC(U%RF(i),m%g(i),e(1),a(1),a(2),k) ! minmin
         if (TF(2)) call a_CC(U%RF(i),m%g(i),e(2),a(1),a(2),k) ! minmax
         if (TF(3)) call a_CC(U%RF(i),m%g(i),e(3),a(1),a(2),k) ! maxmin
         if (TF(4)) call a_CC(U%RF(i),m%g(i),e(4),a(1),a(2),k) ! maxmax
         enddo; enddo
         elseif (U%is_Node) then
         elseif (U%is_Face) then
         elseif (U%is_Edge) then
         endif
       end subroutine

       subroutine a_CC(RF,g,e,d1,d2,dir)
         implicit none
         type(realField),intent(inout) :: RF
         type(grid),intent(in) :: g
         integer,intent(in) :: e
         integer,intent(in) :: dir,d1,d2
         call app_CC_RF(RF%f,RF%b%e(e)%v,RF%b%e(e)%b,RF%s(1),RF%s(2),RF%s(3),&
          CCd1,CCd2,dir,g%c(d1),g%c(d2),dhn_d1,dhn_d2,e)
       end subroutine

       subroutine app_CC_RF(f,v,bct,x,y,z,dir,c1,c2,corner)
         ! At this point, data should be sent in a convention so that the 
         ! next set of routines can handle applying BCs in a systematic way.
         ! Below are some notes and diagrams illustrating this process:
         ! 
         !  NOTES:
         !      $: BC that must be enforced
         !     CC: For Dirichlet, the average of all values must equal BC value
         !         For Neumann, use weighted average, using expression from ref:
         !         Numerical Simulation in Fluid Dynamics a Practical Introduction - M. Griebel et al
         ! 
         !        d2                                                   
         !        ^                                                    
         !        |                                                    
         !        |                                                    
         !         ------- ------- -------- -------- -------          
         !        |       |       |        |        |       |         
         !   2    |  *ug  |  *ug1 |        |  *ug1  |  *ug  |    4    
         !        |       |       |        |        |       |         
         !         -------$------- -------- --------$-------          
         !        |       |       |        |        |       |         
         !        |  *ug2 |  *ui  |        |  *ui   |  *ug2 |         
         !        |       |       |        |        |       |         
         !         ------- ------- -------- -------- -------          
         !        |       |       |        |        |       |         
         !        |       |       |        |        |       |         
         !        |       |       |        |        |       |         
         !         ------- ------- -------- -------- -------          
         !        |       |       |        |        |       |         
         !        |  *ug2 |  *ui  |        |  *ui   |  *ug2 |         
         !        |       |       |        |        |       |         
         !   1     -------$------- -------- --------$-------     3    
         !        |       |       |        |        |       |         
         !        |  *ug  |  *ug1 |        |  *ug1  |  *ug  |         
         !        |       |       |        |        |       |         
         !         ------- ------- -------- -------- ------- -----> d1
         ! 
         !        z                      x                      y                   
         !        ^                      ^                      ^                   
         !        |-----                 |-----                 |-----              
         !        |     |     dir = 1    |     |     dir = 2    |     |     dir = 3
         !        |     |                |     |                |     |             
         !         -------> y             -------> z             -------> x         
         ! 
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: f
         real(cp),dimension(:),intent(in) :: v
         type(bctype),intent(in) :: bct
         type(coordinates),intent(in) :: c1,c2
         integer,intent(in) :: dir,corner
         integer,intent(in) :: x,y,z ! s(1),s(2),s(3)
         select case (corner)
         case (1)
         select case (dir) !                           ug         ui      ug1       ug2
         case (1); call a_CC(bct,c1%dhc(1),c2%dhc(1),v,f(:,1,1),f(:,2,2),f(:,2,1),f(:,1,2))
         case (2); call a_CC(bct,c1%dhc(1),c2%dhc(1),v,f(1,:,1),f(2,:,2),f(1,:,2),f(2,:,1))
         case (3); call a_CC(bct,c1%dhc(1),c2%dhc(1),v,f(1,1,:),f(2,2,:),f(2,1,:),f(1,2,:))
         case default; stop 'Error: dir must = 1,2,3 in app_E_SF in apply_BCs_edges.f90'
         end select
         case (2)
         select case (dir) !                           ug         ui        ug1        ug2
         case (1); call a_CC(bct,c1%dhc(1),c2%dhc_e,v,f(:,1,z),f(:,2,z-1),f(:,2,z),f(:,1,z-1))
         case (2); call a_CC(bct,c1%dhc(1),c2%dhc_e,v,f(x,:,1),f(x-1,:,2),f(x,:,2),f(x-1,:,1))
         case (3); call a_CC(bct,c1%dhc(1),c2%dhc_e,v,f(1,y,:),f(2,y-1,:),f(2,y,:),f(1,y-1,:))
         case default; stop 'Error: dir must = 1,2,3 in app_E_SF in apply_BCs_edges.f90'
         end select
         case (3)
         select case (dir) !                           ug         ui        ug1        ug2
         case (1); call a_CC(bct,c1%dhc_e,c2%dhc(1),v,f(:,y,1),f(:,y-1,2),f(:,y-1,1),f(:,y,2))
         case (2); call a_CC(bct,c1%dhc_e,c2%dhc(1),v,f(1,:,z),f(2,:,z-1),f(1,:,z-1),f(2,:,z))
         case (3); call a_CC(bct,c1%dhc_e,c2%dhc(1),v,f(x,1,:),f(x-1,2,:),f(x-1,1,:),f(x,2,:))
         case default; stop 'Error: dir must = 1,2,3 in app_E_SF in apply_BCs_edges.f90'
         end select
         case (4)
         select case (dir) !                           ug         ui           ug1        ug2
         case (1); call a_CC(bct,c1%dhc_e,c2%dhc_e,v,f(:,y,z),f(:,y-1,z-1),f(:,y-1,z),f(:,y,z-1))
         case (2); call a_CC(bct,c1%dhc_e,c2%dhc_e,v,f(x,:,z),f(x-1,:,z-1),f(x,:,z-1),f(x-1,:,z))
         case (3); call a_CC(bct,c1%dhc_e,c2%dhc_e,v,f(x,y,:),f(x-1,y-1,:),f(x-1,y,:),f(x,y-1,:))
         case default; stop 'Error: dir must = 1,2,3 in app_E_SF in apply_BCs_edges.f90'
         end select
         case default; stop 'Error: corner must = 1,2,3,4 in app_E_SF in apply_BCs_edges.f90'
         end select
       end subroutine

       subroutine a_CC(bct,dh1,dh2,bvals,ug,ui,ug1,ug2)
         !     CC:    ug, ui  , ug1 , ug2
         implicit none
         real(cp),dimension(:),intent(inout) :: ug
         real(cp),dimension(:),intent(in) :: bvals,ui,ug1,ug2
         real(cp),dimension(2),intent(in) :: dh
         type(bctype),intent(in) :: bct
         if (bct%Dirichlet) then;   ug = 4.0_cp*bvals - (ui + ug1 + ug2)
         elseif (bct%Neumann) then; 
         ug = (ug1*dh(1) + ug2*dh(2))/(dh(1)+dh(2)) ! (hard coded zero)
         else; stop 'Error: Bad bctype! Caught in a_CC in apply_BCs_edges.f90'
         endif
       end subroutine

       subroutine a_N(bct,dh,bvals,ub,ug1,ug2,ui1,ui2)
         !     N :    ub, ug1 , ug2 , ui1 , ui2
         implicit none
         real(cp),dimension(:),intent(inout) :: ub,ug1,ug2
         real(cp),dimension(:),intent(in) :: bvals,ui1,ui2
         real(cp),dimension(2),intent(in) :: dh ! needed for non-zero Neumann
         type(bctype),intent(in) :: bct
         if (bct%Dirichlet) then;   ub = bvals
         elseif (bct%Neumann) then; 
           ug1 = ui1 - 2.0_cp*dh(1)*bvals
           ug2 = ui2 - 2.0_cp*dh(2)*bvals
         else; stop 'Error: Bad bctype! Caught in a_N in apply_BCs_edges.f90'
         endif
       end subroutine

       subroutine a_F(bct,dh,bvals,ug,ui)
         !     F :    ug, ui
         implicit none
         real(cp),dimension(:),intent(inout) :: ug
         real(cp),dimension(:),intent(in) :: ui,bvals
         real(cp),intent(in) :: dh
         type(bctype),intent(in) :: bct
         if (bct%Dirichlet) then;   ug = 2.0_cp*bvals - ui
         elseif (bct%Neumann) then; ug = ui + dh*bvals
         else; stop 'Error: Bad bctype! Caught in a_F in apply_BCs_edges.f90'
         endif
       end subroutine


       end module