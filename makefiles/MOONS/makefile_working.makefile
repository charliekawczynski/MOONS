# ****************** OS SETTINGS ********************
ifdef SystemRoot
    PATHSEP2 = \\
	RM = del
else
    PATHSEP2 = /
	RM = rm
endif
PS = $(strip $(PATHSEP2))
# PS1 is needed for gmake clean
PS1 = $(strip \)
extf90 = $(strip .f90)

# ************* MAKE CONFIGURATION ******************
MKE = gmake
# MKE = make
# ************* DIRECTORY SETTINGS ******************
USER = Charlie
# USER = LM_MHD
# USER = charl

# Code directory
SRC_DIR = C:$(PS)Users$(PS)$(USER)$(PS)Documents$(PS)GitHub$(PS)MOONS$(PS)code
# SRC_DIR = C:$(PS)Users$(PS)LM_MHD$(PS)Documents$(PS)GitHub$(PS)MOONS$(PS)code


# Output directory
# TARGET_DIR = C:$(PS)Users$(PS)$(USER)$(PS)Desktop$(PS)MOONS2
# TARGET_DIR = C:$(PS)Users$(PS)$(USER)$(PS)Desktop$(PS)MOONS

# Unit testing directories:
TARGET_DIR = C:$(PS)Users$(PS)$(USER)$(PS)Desktop$(PS)MOONS_unitTest
# TARGET_DIR = C:$(PS)Users$(PS)$(USER)$(PS)Documents$(PS)MOONS_unitTest
# TARGET_DIR = C:$(PS)Users$(PS)$(USER)$(PS)Desktop$(PS)CHARLIE$(PS)MOONS

MOD_DIR = $(TARGET_DIR)$(PS)mod
OBJ_DIR = $(TARGET_DIR)$(PS)obj
LIB_DIR = $(SRC_DIR)$(PS)lib

# **************** INCLUDE PATHS ********************
VPATH =\
	$(TARGET_DIR) \
	$(SRC_DIR)$(PS)lib \
	$(SRC_DIR)$(PS)user \
	$(SRC_DIR)$(PS)BCs \
	$(SRC_DIR)$(PS)BCs$(PS)stitches \
	$(SRC_DIR)$(PS)unit_testing \
	$(SRC_DIR)$(PS)IO \
	$(SRC_DIR)$(PS)grid \
	$(SRC_DIR)$(PS)probes \
	$(SRC_DIR)$(PS)fields \
	$(SRC_DIR)$(PS)ops \
	$(SRC_DIR)$(PS)static \
	$(SRC_DIR)$(PS)computations \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState \
	$(SRC_DIR)$(PS)solvers$(PS)transient \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)energy \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)momentum \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)induction

# ************** COMPILER & STANDARD ****************
FC      = gfortran
# FC      = mpif90
# FC      = mpirun -np 4
# FCFLAGS = -std=f95

# ****************** DEFAULT FLAGS ******************
FCFLAGS = -J"$(MOD_DIR)" -fimplicit-none -Wuninitialized

# ******************** LIBRARIES ********************
# FLIBS = $(LIB_DIR)$(PS)tecio.lib

# ****************** DEBUGGING **********************
# CPU time ~ Debugging level
# FCFLAGS += -g
# FCFLAGS += -g -Wall
# FCFLAGS += -g -Wall -Wextra
# FCFLAGS += -g -Wall -Wextra -fbacktrace
FCFLAGS += -g -Wall -Wextra -fbacktrace -fcheck=all
# FCFLAGS += -g -Wall -Wextra -pedantic -fbacktrace -Q

# **************** OPTIMIZATION *********************
# Speed-up ~ Optimization level
FCFLAGS += -O0
# FCFLAGS += -O1
# FCFLAGS += -O2
# FCFLAGS += -O3
# FCFLAGS += -O4
# FCFLAGS += -O5
# **************** PARALLELIZATION ******************
FCFLAGS += -fopenmp
# FCFLAGS += -mpirun -np 4
# FCFLAGS += -mpif90 -np 4
# FCFLAGS += -mpicc

# ****************** PROFILING **********************
# To profile, run simulation with the flag:
# FCFLAGS += -pg
# Then run the following command:
# gprof MOONS.exe > timeReport.txt

# *********** PRE-PROCESSOR DIRECTIVES **************
FCFLAGS += -cpp

# *********** PRE-PROCESSOR DEFINITIONS *************
# Precision
# FCFLAGS += -D_SINGLE_PRECISION_
FCFLAGS += -D_DOUBLE_PRECISION_
# FCFLAGS += -D_QUAD_PRECISION_

# FFT Methods
# FCFLAGS += -D_FFT_FULL_
FCFLAGS += -D_FFT_RADIX2_

# Order of accuracy
FCFLAGS += -D_STENCILS_O2_
# FCFLAGS += -D_STENCILS_O4_

# Parallelization
# FCFLAGS += -D_PARALLELIZE_Jacobi_
FCFLAGS += -D_PARALLELIZE_SOR_
FCFLAGS += -D_PARALLELIZE_RF_
FCFLAGS += -D_PARALLELIZE_EMBEDEXTRACT_

# FCFLAGS += noarg_temp_created

# Code verification
# FCFLAGS += -D_EXPORT_JAC_CONVERGENCE_
# FCFLAGS += -D_EXPORT_SOR_CONVERGENCE_
# FCFLAGS += -D_EXPORT_CG_CONVERGENCE_
# FCFLAGS += -D_EXPORT_ADI_CONVERGENCE_
# FCFLAGS += -D_EXPORT_MG_CONVERGENCE_

# Internal debugging
FCFLAGS += -D_DEBUG_DEL_
FCFLAGS += -D_DEBUG_INTERP_
# FCFLAGS += -D_DEBUG_COORDINATES_
FCFLAGS += -D_DEBUG_APPLYBCS_
# FCFLAGS += -D_DEBUG_RF_
# FCFLAGS += -D_DEBUG_SF_
# FCFLAGS += -D_DEBUG_VF_
# FCFLAGS += -D_DEBUG_TF_


# TARGET = $(TARGET_DIR)$(PS)MOONS
TARGET = $(TARGET_DIR)$(PS)unitTest

# **************** SOURCE FILES *********************
# $(SRC_DIR)$(PS)static$(PS)dataSet.f90 \
# $(SRC_DIR)$(PS)static$(PS)varStr.f90 \

# $(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)PseudoTime.f90 \
# $(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)jacobi.f90 \
# $(SRC_DIR)$(PS)solvers$(PS)transient$(PS)ADI.f90 \

# $(SRC_DIR)$(PS)solvers$(PS)transient$(PS)induction$(PS)ind_methods.f90 \
# $(SRC_DIR)$(PS)solvers$(PS)transient$(PS)induction$(PS)ind_CTM.f90 \

# $(SRC_DIR)$(PS)IO$(PS)IO_tecplotHeaders.f90 \


SRCS_F =\
	$(SRC_DIR)$(PS)IO$(PS)IO_tools.f90 \
	$(SRC_DIR)$(PS)IO$(PS)exp_Tecplot_Zone.f90 \
	$(SRC_DIR)$(PS)IO$(PS)exp_Tecplot_Header.f90 \
	$(SRC_DIR)$(PS)IO$(PS)IO_auxiliary.f90 \
	$(SRC_DIR)$(PS)static$(PS)array.f90 \
	$(SRC_DIR)$(PS)static$(PS)sparse.f90 \
	$(SRC_DIR)$(PS)static$(PS)triDiag.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)stitches$(PS)stitch_face.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)stitches$(PS)stitch_edge.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)stitches$(PS)stitch_corner.f90 \
	$(SRC_DIR)$(PS)grid$(PS)coordinates.f90 \
	$(SRC_DIR)$(PS)grid$(PS)grid.f90 \
	$(SRC_DIR)$(PS)grid$(PS)grid_distribution_funcs.f90 \
	$(SRC_DIR)$(PS)grid$(PS)grid_genHelper.f90 \
	$(SRC_DIR)$(PS)grid$(PS)grid_stretchParamMatch.f90 \
	$(SRC_DIR)$(PS)grid$(PS)grid_init.f90 \
	$(SRC_DIR)$(PS)grid$(PS)grid_extend.f90 \
	$(SRC_DIR)$(PS)grid$(PS)grid_connect.f90 \
	$(SRC_DIR)$(PS)grid$(PS)grid_generate.f90 \
	$(SRC_DIR)$(PS)grid$(PS)mesh.f90 \
	$(SRC_DIR)$(PS)user$(PS)simParams.f90 \
	$(SRC_DIR)$(PS)grid$(PS)subdomain.f90 \
	$(SRC_DIR)$(PS)grid$(PS)domain.f90 \
	$(SRC_DIR)$(PS)grid$(PS)mesh_geometries.f90 \
	$(SRC_DIR)$(PS)grid$(PS)mesh_generate.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)bctype.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)corner.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)edge.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)face.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)BCs.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)vectorBCs.f90 \
	$(SRC_DIR)$(PS)fields$(PS)RF.f90 \
	$(SRC_DIR)$(PS)fields$(PS)SF.f90 \
	$(SRC_DIR)$(PS)fields$(PS)VF.f90 \
	$(SRC_DIR)$(PS)fields$(PS)TF.f90 \
	$(SRC_DIR)$(PS)IO$(PS)export_raw.f90 \
	$(SRC_DIR)$(PS)IO$(PS)export_g.f90 \
	$(SRC_DIR)$(PS)IO$(PS)export_SF.f90 \
	$(SRC_DIR)$(PS)IO$(PS)export_VF.f90 \
	$(SRC_DIR)$(PS)IO$(PS)import_raw.f90 \
	$(SRC_DIR)$(PS)IO$(PS)import_g.f90 \
	$(SRC_DIR)$(PS)IO$(PS)import_SF.f90 \
	$(SRC_DIR)$(PS)IO$(PS)import_VF.f90 \
	$(SRC_DIR)$(PS)IO$(PS)IO_SF.f90 \
	$(SRC_DIR)$(PS)IO$(PS)IO_VF.f90 \
	$(SRC_DIR)$(PS)static$(PS)version.f90 \
	$(SRC_DIR)$(PS)static$(PS)solverSettings.f90 \
	$(SRC_DIR)$(PS)static$(PS)myTime.f90 \
	$(SRC_DIR)$(PS)computations$(PS)norms.f90 \
	$(SRC_DIR)$(PS)user$(PS)rundata.f90 \
	$(SRC_DIR)$(PS)ops$(PS)apply_stitches_faces.f90 \
	$(SRC_DIR)$(PS)ops$(PS)apply_stitches_edges.f90 \
	$(SRC_DIR)$(PS)ops$(PS)apply_stitches_corners.f90 \
	$(SRC_DIR)$(PS)ops$(PS)apply_stitches.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_fft.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_dct.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_idct.f90 \
	$(SRC_DIR)$(PS)computations$(PS)stencils.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_del.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_split.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_interp.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_embedExtract.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_aux.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_discrete.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_physics.f90 \
	$(SRC_DIR)$(PS)ops$(PS)ops_discrete_complex.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)apply_BCs_faces.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)apply_BCs_edges.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)apply_BCs_corners.f90 \
	$(SRC_DIR)$(PS)BCs$(PS)apply_BCs.f90 \
	$(SRC_DIR)$(PS)static$(PS)probe_transient.f90 \
	$(SRC_DIR)$(PS)static$(PS)probe_base.f90 \
	$(SRC_DIR)$(PS)static$(PS)probe_derived.f90 \
	$(SRC_DIR)$(PS)static$(PS)monitor.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)triSolver.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)FFT_poisson.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)JAC_ops.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)SOR.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)PSE.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)CG.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)CG_ind.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)MG_tools.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)MG.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)steadyState$(PS)poisson.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)energy$(PS)init_TBCs.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)energy$(PS)init_Tfield.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)energy$(PS)init_K.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)induction$(PS)init_BBCs.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)induction$(PS)init_Bfield.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)induction$(PS)init_Sigma.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)momentum$(PS)profile_funcs.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)momentum$(PS)init_UBCs.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)momentum$(PS)init_PBCs.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)momentum$(PS)init_Ufield.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)momentum$(PS)init_Pfield.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)energy$(PS)energySolver.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)induction$(PS)inductionSolver.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)momentum$(PS)momentumSolver.f90 \
	$(SRC_DIR)$(PS)solvers$(PS)transient$(PS)MHDSolver.f90 \
	$(SRC_DIR)$(PS)user$(PS)MOONS.f90 \
	$(SRC_DIR)$(PS)static$(PS)richardsonExtrapolation.f90 \
	$(SRC_DIR)$(PS)user$(PS)convergenceRate.f90


# SRCS_F += $(SRC_DIR)$(PS)unit_testing$(PS)test_triSolver.f90
# SRCS_F += $(SRC_DIR)$(PS)unit_testing$(PS)test_SOR.f90
# SRCS_F += $(SRC_DIR)$(PS)unit_testing$(PS)test_complexG.f90
# SRCS_F += $(SRC_DIR)$(PS)unit_testing$(PS)test_JAC.f90
SRCS_F += $(SRC_DIR)$(PS)unit_testing$(PS)test_CG.f90
# SRCS_F += $(SRC_DIR)$(PS)unit_testing$(PS)test_MG.f90

SRCS_F += $(TARGET_DIR)$(PS)parametricStudy.f90

# **************** DO NOT EDIT BELOW HERE *********************
# **************** DO NOT EDIT BELOW HERE *********************
# **************** DO NOT EDIT BELOW HERE *********************


OBJS_F = $(patsubst %.f90,$(OBJ_DIR)$(PS)%.o,$(notdir $(SRCS_F)))

all: $(TARGET)

$(TARGET): $(OBJS_F)
	$(FC) -o $@ $(FCFLAGS) $(OBJS_F) $(FLIBS)

$(OBJ_DIR)$(PS)%.o: %.f90
	$(FC) $(FCFLAGS) -c -o $@ $<

clean:
	$(RM) $(subst $(PS),$(PS1),$(MOD_DIR)$(PS)*.mod)
	$(RM) $(subst $(PS),$(PS1),$(OBJ_DIR)$(PS)*.o)
	$(RM) $(subst $(PS),$(PS1),$(TARGET).exe)
	$(RM) $(subst $(PS),$(PS1),$(TARGET))

run: myRun
myRun: $(TARGET)
	cd $(TARGET_DIR) && MKE run

info:;  @echo " "
	@echo " "
	@echo "Source files:"
	@echo $(SRCS_F)
	@echo " "
	@echo "Object files:"
	@echo $(OBJS_F)
	@echo " "
	@echo "Compiler          : $(FC)"
	@echo "Library directory : $(LIB_DIR)"
	@echo "Target directory  : $(TARGET_DIR)"
	@echo "Modules directory : $(MOD_DIR)"
	@echo "Object directory  : $(OBJ_DIR)"
	@echo " "