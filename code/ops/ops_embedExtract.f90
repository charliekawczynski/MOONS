       module ops_embedExtract_mod
       ! Not all embed / extract routines are used for each method. For example,
       ! the CT method only uses embedEdge, and not embedCC or embedFace.
       ! 
       ! Pre-processor directives: (_PARALLELIZE_EMBEDEXTRACT_,_DEBUG_EMBEDEXTRACT_)

       use current_precision_mod
       use overlap_mod
       use mesh_mod
       use mesh_domain_mod
       use GF_mod
       use SF_mod
       use VF_mod

       implicit none

       private
       public :: extract,extractCC,extractFace,extractEdge
       public :: embed,embedCC,embedFace,embedEdge

       interface extract;        module procedure extract_SF;        end interface
       interface extract;        module procedure extract_VF;        end interface
       interface extractCC;      module procedure extractCC_SF;      end interface
       interface extractCC;      module procedure extractCC_VF;      end interface
       interface extractFace;    module procedure extractFace_SF;    end interface
       interface extractFace;    module procedure extractFace_VF;    end interface
       interface extractEdge;    module procedure extractEdge_SF;    end interface
       interface extractEdge;    module procedure extractEdge_VF;    end interface

       interface embed;          module procedure embed_SF;          end interface
       interface embed;          module procedure embed_VF;          end interface
       interface embedCC;        module procedure embedCC_SF;        end interface
       interface embedCC;        module procedure embedCC_VF;        end interface
       interface embedFace;      module procedure embedFace_SF;      end interface
       interface embedFace;      module procedure embedFace_VF;      end interface
       interface embedEdge;      module procedure embedEdge_SF;      end interface
       interface embedEdge;      module procedure embedEdge_VF;      end interface

       interface EX;             module procedure extract_GF;        end interface
       interface EM;             module procedure embed_GF;          end interface

       contains

       ! *********************************************************************************
       ! *********************************************************************************
       ! ***************************** LOW-LEVEL ROUTINE *********************************
       ! *********************************************************************************
       ! *********************************************************************************

       subroutine embedExtract_GF_raw(A,B,A1,A2,B1,B2)
         ! This is the embed/extract (EE) routine.
         implicit none
         type(grid_field),intent(inout) :: A
         type(grid_field),intent(in) :: B
         integer,dimension(3),intent(in) :: A1,A2,B1,B2
#ifdef _PARALLELIZE_EMBEDEXTRACT_
         integer :: i,j,k
         integer,dimension(3) :: suppress_warning
         suppress_warning = B2 ! B2 is not needed for parallel computations
         !$OMP PARALLEL DO
         do k=A1(3),A2(3);do j=A1(2),A2(2);do i=A1(1),A2(1)
         A%f(i,j,k) = B%f(B1(1)+(i-A1(1)),B1(2)+(j-A1(2)),B1(3)+(k-A1(3)))
         enddo; enddo; enddo
         !$OMP END PARALLEL DO
#else
         A%f(A1(1):A2(1),A1(2):A2(2),A1(3):A2(3)) = &
         B%f(B1(1):B2(1),B1(2):B2(2),B1(3):B2(3))
#endif
       end subroutine

       subroutine embed_GF(A,B,AB,caller)
         implicit none
         type(grid_field),intent(inout) :: A
         type(grid_field),intent(in) :: B
         type(overlap),dimension(3),intent(in) :: AB
         character(len=*),intent(in) :: caller
         call embedExtract_GF_raw(A,B,AB(1:3)%i2(1),&
                                      AB(1:3)%i2(2),&
                                      AB(1:3)%i1(1),&
                                      AB(1:3)%i1(2))
       end subroutine
       subroutine extract_GF(A,B,AB,caller)
         implicit none
         type(grid_field),intent(inout) :: A
         type(grid_field),intent(in) :: B
         type(overlap),dimension(3),intent(in) :: AB
         character(len=*),intent(in) :: caller
         call embedExtract_GF_raw(A,B,AB(1:3)%i1(1),&
                                      AB(1:3)%i1(2),&
                                      AB(1:3)%i2(1),&
                                      AB(1:3)%i2(2))
       end subroutine

       ! *********************************************************************************
       ! ********************** CASE SPECIFIC EXTRACT ROUTINES ***************************
       ! *********************************************************************************

       subroutine extract_SF(interior,total,MD)
         implicit none
         type(SF),intent(inout) :: interior
         type(SF),intent(in) :: total
         type(mesh_domain),intent(in) :: MD
         if (total%is_CC) then;       call extractCC(interior,total,MD)
         elseif (total%is_Node) then; ! call extractNode(interior,total,MD)
         stop 'Error: N not supported in extract_SF in ops_embedExtract.f90'
         elseif (total%is_Face) then; call extractFace(interior,total,MD)
         elseif (total%is_Edge) then; call extractEdge(interior,total,MD)
         else; stop 'Error: bad data input to extract_F in embedExtract.f90'
         endif
       end subroutine
       subroutine extract_VF(interior,total,MD)
         implicit none
         type(VF),intent(inout) :: interior
         type(VF),intent(in) :: total
         type(mesh_domain),intent(in) :: MD
         call extract(interior%x,total%x,MD)
         call extract(interior%y,total%y,MD)
         call extract(interior%z,total%z,MD)
       end subroutine

       subroutine extractCC_SF(CC_i,CC_t,MD)
         implicit none
         type(SF),intent(inout) :: CC_i
         type(SF),intent(in) :: CC_t
         type(mesh_domain),intent(in) :: MD
         integer :: i
#ifdef _DEBUG_EMBEDEXTRACT_
         if (.not.CC_i%is_CC) stop 'Error: CC data not found (1) in extractCC_SF in ops_embedExtract.f90'
         if (.not.CC_t%is_CC) stop 'Error: CC data not found (2) in extractCC_SF in ops_embedExtract.f90'
#endif
         do i=1,MD%D%s
         call EX(CC_i%BF(MD%D%sd(i)%g_R1_id)%GF,CC_t%BF(MD%D%sd(i)%g_R2_id)%GF,EE_shape(CC_i,MD,i),'extractCC_SF')
         enddo
       end subroutine
       subroutine extractCC_VF(CC_i,CC_t,MD)
         implicit none
         type(VF),intent(inout) :: CC_i
         type(VF),intent(in) :: CC_t
         type(mesh_domain),intent(in) :: MD
         call extractCC_SF(CC_i%x,CC_t%x,MD)
         call extractCC_SF(CC_i%y,CC_t%y,MD)
         call extractCC_SF(CC_i%z,CC_t%z,MD)
       end subroutine

       subroutine extractFace_SF(face_i,face_t,MD) ! Extracts Lorentz force from induction to momentum
         implicit none
         type(SF),intent(inout) :: face_i
         type(SF),intent(in) :: face_t
         type(mesh_domain),intent(in) :: MD
         integer :: i
#ifdef _DEBUG_EMBEDEXTRACT_
         if (.not.face_t%is_Face) stop 'Error: face data not found (1) in extractFace_SF in ops_embedExtract.f90'
         if (.not.face_i%is_Face) stop 'Error: face data not found (2) in extractFace_SF in ops_embedExtract.f90'
#endif
         do i=1,MD%D%s
         call EX(face_i%BF(MD%D%sd(i)%g_R1_id)%GF,face_t%BF(MD%D%sd(i)%g_R2_id)%GF,EE_shape(face_i,MD,i),'extractFace_SF')
         enddo
       end subroutine
       subroutine extractFace_VF(face_i,face_t,MD) ! Extracts Lorentz force from induction to momentum
         implicit none
         type(VF),intent(inout) :: face_i
         type(VF),intent(in) :: face_t
         type(mesh_domain),intent(in) :: MD
         call extractFace_SF(face_i%x,face_t%x,MD)
         call extractFace_SF(face_i%y,face_t%y,MD)
         call extractFace_SF(face_i%z,face_t%z,MD)
       end subroutine

       subroutine extractEdge_SF(edge_i,edge_t,MD) ! Auxiliary (energy budget)
         implicit none
         type(SF),intent(inout) :: edge_i
         type(SF),intent(in) :: edge_t
         type(mesh_domain),intent(in) :: MD
         integer :: i
#ifdef _DEBUG_EMBEDEXTRACT_
         if (.not.edge_i%is_Edge) stop 'Error: edge data not found (1) in extractEdge_SF in ops_embedExtract.f90'
         if (.not.edge_t%is_Edge) stop 'Error: edge data not found (2) in extractEdge_SF in ops_embedExtract.f90'
#endif
         do i=1,MD%D%s
         call EX(edge_i%BF(MD%D%sd(i)%g_R1_id)%GF,edge_t%BF(MD%D%sd(i)%g_R2_id)%GF,EE_shape(edge_i,MD,i),'extractEdge_SF')
         enddo
       end subroutine
       subroutine extractEdge_VF(edge_i,edge_t,MD) ! Auxiliary (energy budget)
         implicit none
         type(VF),intent(inout) :: edge_i
         type(VF),intent(in) :: edge_t
         type(mesh_domain),intent(in) :: MD
         call extractEdge_SF(edge_i%x,edge_t%x,MD)
         call extractEdge_SF(edge_i%y,edge_t%y,MD)
         call extractEdge_SF(edge_i%z,edge_t%z,MD)
       end subroutine

       ! *********************************************************************************
       ! ************************ CASE SPECIFIC EMBED ROUTINES ***************************
       ! *********************************************************************************

       subroutine embed_SF(total,interior,MD)
         implicit none
         type(SF),intent(inout) :: total
         type(SF),intent(in) :: interior
         type(mesh_domain),intent(in) :: MD
         if (total%is_CC) then;       call embedCC(total,interior,MD)
         elseif (total%is_Node) then; ! call embedNode(total,interior,MD)
         stop 'Error: N not supported in embed_SF in ops_embedExtract.f90'
         elseif (total%is_Face) then; call embedFace(total,interior,MD)
         elseif (total%is_Edge) then; call embedEdge(total,interior,MD)
         else; stop 'Error: bad data input to extract_F in embedExtract.f90'
         endif
       end subroutine
       subroutine embed_VF(total,interior,MD)
         implicit none
         type(VF),intent(inout) :: total
         type(VF),intent(in) :: interior
         type(mesh_domain),intent(in) :: MD
         call embed(total%x,interior%x,MD)
         call embed(total%y,interior%y,MD)
         call embed(total%z,interior%z,MD)
       end subroutine

       subroutine embedCC_SF(CC_t,CC_i,MD) ! For material properties
         implicit none
         type(SF),intent(inout) :: CC_t
         type(SF),intent(in) :: CC_i
         type(mesh_domain),intent(in) :: MD
         integer :: i
#ifdef _DEBUG_EMBEDEXTRACT_
         if (.not.CC_i%is_CC) stop 'Error: CC data not found (1) in embedCC_SF in ops_embedExtract.f90'
         if (.not.CC_t%is_CC) stop 'Error: CC data not found (2) in embedCC_SF in ops_embedExtract.f90'
#endif
         do i=1,MD%D%s
         call EM(CC_t%BF(MD%D%sd(i)%g_R2_id)%GF,CC_i%BF(MD%D%sd(i)%g_R1_id)%GF,EE_shape(CC_t,MD,i),'embedCC_SF')
         enddo
       end subroutine
       subroutine embedCC_VF(CC_t,CC_i,MD)
         implicit none
         type(VF),intent(inout) :: CC_t
         type(VF),intent(in) :: CC_i
         type(mesh_domain),intent(in) :: MD
         call embedCC_SF(CC_t%x,CC_i%x,MD)
         call embedCC_SF(CC_t%y,CC_i%y,MD)
         call embedCC_SF(CC_t%z,CC_i%z,MD)
       end subroutine

       subroutine embedFace_SF(Face_t,Face_i,MD)
         implicit none
         type(SF),intent(inout) :: Face_t
         type(SF),intent(in) :: Face_i
         type(mesh_domain),intent(in) :: MD
         integer :: i
#ifdef _DEBUG_EMBEDEXTRACT_
         if (.not.Face_i%is_Face) stop 'Error: Face data not found (1) in embedFace_SF in ops_embedExtract.f90'
         if (.not.Face_t%is_Face) stop 'Error: Face data not found (2) in embedFace_SF in ops_embedExtract.f90'
#endif
         do i=1,MD%D%s
         call EM(Face_t%BF(MD%D%sd(i)%g_R2_id)%GF,Face_i%BF(MD%D%sd(i)%g_R1_id)%GF,EE_shape(Face_t,MD,i),'embedFace_SF')
         enddo
       end subroutine
       subroutine embedFace_VF(Face_t,Face_i,MD)
         implicit none
         type(VF),intent(inout) :: Face_t
         type(VF),intent(in) :: Face_i
         type(mesh_domain),intent(in) :: MD
         call embedFace_SF(face_t%x,face_i%x,MD)
         call embedFace_SF(face_t%y,face_i%y,MD)
         call embedFace_SF(face_t%z,face_i%z,MD)
       end subroutine

       subroutine embedEdge_SF(Edge_t,Edge_i,MD) ! Embeds velocity from momentum into induction
         implicit none
         type(SF),intent(inout) :: Edge_t
         type(SF),intent(in) :: Edge_i
         type(mesh_domain),intent(in) :: MD
         integer :: i
#ifdef _DEBUG_EMBEDEXTRACT_
         if (.not.edge_t%is_Edge) stop 'Error: edge data not found (1) in embedEdge_SF in ops_embedExtract.f90'
         if (.not.edge_i%is_Edge) stop 'Error: edge data not found (2) in embedEdge_SF in ops_embedExtract.f90'
#endif
         do i=1,MD%D%s
         call EM(Edge_t%BF(MD%D%sd(i)%g_R2_id)%GF,Edge_i%BF(MD%D%sd(i)%g_R1_id)%GF,EE_shape(Edge_t,MD,i),'embedFace_VF')
         enddo
       end subroutine
       subroutine embedEdge_VF(Edge_t,Edge_i,MD) ! Embeds velocity from momentum into induction
         implicit none
         type(VF),intent(inout) :: Edge_t
         type(VF),intent(in) :: Edge_i
         type(mesh_domain),intent(in) :: MD
         call embedEdge_SF(Edge_t%x,Edge_i%x,MD)
         call embedEdge_SF(Edge_t%y,Edge_i%y,MD)
         call embedEdge_SF(Edge_t%z,Edge_i%z,MD)
       end subroutine

       ! *********************************************************************************
       ! ****************************** INDEX DETAILS ************************************
       ! *********************************************************************************

       ! type subdomain
       !   ! Legend:
       !   !        C = Cell Center
       !   !              E = exclude first exterior point
       !   !              I = include first exterior point
       !   !        N = Node
       !   !              B = include boundary point (for node data)
       !   !              I = include first exterior point
       !   !              E = exclude boundary point
       !   !        T = total mesh_domain (fluid, e.g.)
       !   type(overlap),dimension(3) :: CE
       !   type(overlap),dimension(3) :: CI
       !   type(overlap),dimension(3) :: NB
       !   type(overlap),dimension(3) :: NI
       !   logical,dimension(3) :: defined = .false.
       !   integer :: g_R1_id,g_R2_id
       ! end type

       function EE_shape(f,MD,i) result(s)
         implicit none
         type(SF),intent(in) :: f
         type(mesh_domain),intent(in) :: MD
         integer,intent(in) :: i
         type(overlap),dimension(3) :: s
         s = MD%D%sd(i)%phys_all
       end function

       end module