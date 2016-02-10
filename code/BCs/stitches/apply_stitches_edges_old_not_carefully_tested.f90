       module apply_stitches_edges_mod
       ! Notes:
       !       o Edge stitching is necessary in scenarios where two grids 
       !         share an edge. An example is below
       ! 
       !       o Example: Here, g1 and g2 share an edge, and information 
       !         between the diagonal fields must share information because
       !         the ghost points for g1 are in the real, physical, domain
       !         in g2. Note that the adjacent grids cannot share edge 
       !         information becuase they are ghost points to each other!
       ! 
       !                |       *       |        
       !                |       *       |   g2   
       !                |       *       |        
       !        -------- ------- ---F---N--------
       !                |       *       |        
       !                |       *   C   F        
       !                |       *       |        
       !        ******** ******* ******* ********  * = physical boundary
       !                |       *       |        
       !                F   C   *       |        
       !                |       *       |        
       !        --------N---F--- ------- --------
       !                |       *       |        
       !           g1   |       *       |        
       !                |       *       |        
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
       use RF_mod
       use SF_mod
       use VF_mod
       use mesh_mod
       implicit none

       private
       public :: apply_stitches_edges

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

       interface apply_stitches_edges;    module procedure apply_stitches_edges_VF;     end interface
       interface apply_stitches_edges;    module procedure apply_stitches_edges_SF;     end interface

       contains

       subroutine apply_stitches_edges_VF(U,m)
         implicit none
         type(VF),intent(inout) :: U
         type(mesh),intent(in) :: m
         call apply_stitches_edges(U%x,m)
         call apply_stitches_edges(U%y,m)
         call apply_stitches_edges(U%z,m)
       end subroutine

       subroutine apply_stitches_edges_SF(U,m)
         implicit none
         type(SF),intent(inout) :: U
         type(mesh),intent(in) :: m
         integer :: i,k
         if (U%is_CC) then
           do i=1,m%s; do k=1,3
           if (m%g(i)%st_face%hmin(k)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(k)),k,0,0,0)
           enddo; enddo
         elseif (U%is_Node) then
           do i=1,m%s; do k=1,3
           if (m%g(i)%st_face%hmin(k)) call app_N(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(k)),k,1,1,1)
           enddo; enddo
         elseif (U%is_Face) then
            select case (U%Face)
            case (1); do i=1,m%s
                      if (m%g(i)%st_face%hmin(1)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(1)),1,0,0,0)
                      if (m%g(i)%st_face%hmin(2)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(2)),2,1,0,0)
                      if (m%g(i)%st_face%hmin(3)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(3)),3,1,0,0)
                      enddo
            case (2); do i=1,m%s
                      if (m%g(i)%st_face%hmin(1)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(1)),1,0,1,0)
                      if (m%g(i)%st_face%hmin(2)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(2)),2,0,0,0)
                      if (m%g(i)%st_face%hmin(3)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(3)),3,0,1,0)
                      enddo
            case (3); do i=1,m%s
                      if (m%g(i)%st_face%hmin(1)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(1)),1,0,0,1)
                      if (m%g(i)%st_face%hmin(2)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(2)),2,0,0,1)
                      if (m%g(i)%st_face%hmin(3)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(3)),3,0,0,0)
                      enddo
            case default; stop 'Error: face must = 1,2,3 in apply_stitches_edges.f90'
            end select
         elseif (U%is_Edge) then
            select case (U%Edge)
            case (1); do i=1,m%s
                      if (m%g(i)%st_face%hmin(1)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(1)),1,0,1,1)
                      if (m%g(i)%st_face%hmin(2)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(2)),2,0,0,1)
                      if (m%g(i)%st_face%hmin(3)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(3)),3,0,1,0)
                      enddo
            case (2); do i=1,m%s
                      if (m%g(i)%st_face%hmin(1)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(1)),1,0,0,1)
                      if (m%g(i)%st_face%hmin(2)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(2)),2,1,0,1)
                      if (m%g(i)%st_face%hmin(3)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(3)),3,1,0,0)
                      enddo
            case (3); do i=1,m%s
                      if (m%g(i)%st_face%hmin(1)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(1)),1,0,1,0)
                      if (m%g(i)%st_face%hmin(2)) call app_N( U%RF(i),U%RF(m%g(i)%st_face%hmin_id(2)),2,1,0,0)
                      if (m%g(i)%st_face%hmin(3)) call app_CC(U%RF(i),U%RF(m%g(i)%st_face%hmin_id(3)),3,1,1,0)
                      enddo
            case default; stop 'Error: edge must = 1,2,3 in apply_stitches_edges.f90'
            end select
         else
          write(*,*) 'dir = ',k
          write(*,*) 'U%is_CC = ',U%is_CC
          write(*,*) 'U%is_Node = ',U%is_Node
          write(*,*) 'U%is_Face = ',U%is_Face
          write(*,*) 'U%is_Edge = ',U%is_Edge
          write(*,*) 'U%Face = ',U%Face
          write(*,*) 'U%Edge = ',U%Edge
          stop 'Error: data type not found in apply_stitches_edges.f90'
         endif
       end subroutine

       subroutine app_CC(Umin,Umax,dir,px,py,pz)
         ! Along direction dir, we have
         ! 
         !            Umax (attaches at hmax)
         !       |-------------------------------|        Umin (attaches at hmin)
         !                                       |-----------------------------------|
         ! 

         implicit none
         type(realField),intent(inout) :: Umin,Umax
         integer,intent(in) :: dir,px,py,pz
         select case (dir)
         case (1); Umax%f(  Umax%s(1)  ,2+py:Umax%s(2)-1-py,2+pz:Umax%s(3)-1-pz) = &
                   Umin%f(    2        ,2+py:Umax%s(2)-1-py,2+pz:Umax%s(3)-1-pz)
                   Umin%f(    1        ,2+py:Umin%s(2)-1-py,2+pz:Umin%s(3)-1-pz) = &
                   Umax%f(  Umax%s(1)-1,2+py:Umin%s(2)-1-py,2+pz:Umin%s(3)-1-pz)
         case (2); Umax%f(2+px:Umax%s(1)-1-px,  Umax%s(2)  ,2+pz:Umax%s(3)-1-pz) = &
                   Umin%f(2+px:Umin%s(1)-1-px,    2        ,2+pz:Umax%s(3)-1-pz)
                   Umin%f(2+px:Umin%s(1)-1-px,    1        ,2+pz:Umin%s(3)-1-pz) = &
                   Umax%f(2+px:Umax%s(1)-1-px,  Umax%s(2)-1,2+pz:Umin%s(3)-1-pz)
         case (3); Umax%f(2+px:Umax%s(1)-1-px,2+py:Umax%s(2)-1-py,  Umax%s(3)  ) = &
                   Umin%f(2+px:Umin%s(1)-1-px,2+py:Umax%s(2)-1-py,    2        )
                   Umin%f(2+px:Umin%s(1)-1-px,2+py:Umin%s(2)-1-py,    1        ) = &
                   Umax%f(2+px:Umax%s(1)-1-px,2+py:Umin%s(2)-1-py,  Umax%s(3)-1)
         case default
         stop 'Error: dir must = 1,2,3 in applyAllStitches_RF in apply_stitches_edges.f90'
         end select
       end subroutine

       subroutine app_N(Umin,Umax,dir,px,py,pz)
         ! Along direction dir, we have
         ! 
         !            Umax (attaches at hmax)
         !       |-------------------------------|        Umin (attaches at hmin)
         !                                       |-----------------------------------|
         ! 

         implicit none
         type(realField),intent(inout) :: Umin,Umax
         integer,intent(in) :: dir,px,py,pz
         select case (dir)
         case (1); Umax%f(  Umax%s(1)  ,2+py:Umax%s(2)-1-py,2+pz:Umax%s(3)-1-pz) = &
                   Umin%f(    3        ,2+py:Umax%s(2)-1-py,2+pz:Umax%s(3)-1-pz)
                   Umin%f(    1        ,2+py:Umin%s(2)-1-py,2+pz:Umin%s(3)-1-pz) = &
                   Umax%f(  Umax%s(1)-2,2+py:Umin%s(2)-1-py,2+pz:Umin%s(3)-1-pz)
         case (2); Umax%f(2+px:Umax%s(1)-1-px,  Umax%s(2)  ,2+pz:Umax%s(3)-1-pz) = &
                   Umin%f(2+px:Umin%s(1)-1-px,    3        ,2+pz:Umax%s(3)-1-pz)
                   Umin%f(2+px:Umin%s(1)-1-px,    1        ,2+pz:Umin%s(3)-1-pz) = &
                   Umax%f(2+px:Umax%s(1)-1-px,  Umax%s(2)-2,2+pz:Umin%s(3)-1-pz)
         case (3); Umax%f(2+px:Umax%s(1)-1-px,2+py:Umax%s(2)-1-py,  Umax%s(3)  ) = &
                   Umin%f(2+px:Umin%s(1)-1-px,2+py:Umax%s(2)-1-py,    3        )
                   Umin%f(2+px:Umin%s(1)-1-px,2+py:Umin%s(2)-1-py,    1        ) = &
                   Umax%f(2+px:Umax%s(1)-1-px,2+py:Umin%s(2)-1-py,  Umax%s(3)-2)
         case default
         stop 'Error: dir must = 1,2,3 in applyAllStitches_RF in apply_stitches_edges.f90'
         end select
       end subroutine

       end module