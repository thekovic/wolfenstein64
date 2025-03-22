BUILD_DIR=build
SOURCE_DIR=src
include $(N64_INST)/include/n64.mk

N64_CFLAGS := $(filter-out -Werror -O2,$(N64_CFLAGS)) -I$(BUILD_DIR) -Os
N64_CXXFLAGS := $(filter-out -Werror -O2,$(N64_CXXFLAGS)) -I$(BUILD_DIR) -Os
OPTIONS :=

GAME ?= wolf

ifdef NOWAIT
	OPTIONS += NOWAIT=true
else
	OPTIONS += NOWAIT=false
endif
ifdef WARP
	OPTIONS += DEVWARP=$(WARP)
endif
ifdef SKILL
	OPTIONS += DEVSKILL=$(SKILL)
endif

asset_names := audiohed audiot gamemaps maphead vgadict vgahead vgagraph vswap

ifeq ($(GAME),spear)
  ROMTITLE := "\"Spear64\""
  ROMNAME := spear64
  OPTIONS += CARMACIZED SPEAR GOODTIMES
  assets := $(addsuffix .sod,$(asset_names))
else ifeq ($(GAME),speardemo)
  ROMTITLE := "\"SpearDemo64\""
  ROMNAME := speardemo64
  OPTIONS += CARMACIZED SPEAR SPEARDEMO
  assets := $(addsuffix .sdm,$(asset_names))
else ifeq ($(GAME),wolfdemo)
  ROMTITLE := "\"WolfDemo64\""
  ROMNAME := wolfdemo64
  OPTIONS += CARMACIZED UPLOAD
  assets := $(addsuffix .wl1,$(asset_names))
else ifeq ($(GAME),wolf)
  ROMTITLE := "\"Wolfenstein64\""
  ROMNAME := wolf64
  OPTIONS += CARMACIZED GOODTIMES
  assets := $(addsuffix .wl6,$(asset_names))
else
	$(error Unknown game $(GAME))
endif

OPTIONS += GAMETITLE=$(ROMTITLE) ROMNAME="\"$(ROMNAME)\""

# Set DFS root to appropriate game version
N64_MKDFS_ROOT := $(N64_MKDFS_ROOT)/$(GAME)
# Convert OPTIONS to GCC -D flags
DEFINES = $(foreach opt,$(OPTIONS),-D$(opt))
N64_CFLAGS += $(DEFINES)

$(shell mkdir -p $(BUILD_DIR))

SOURCE_FILES := id_ca.c id_in.c id_pm.c id_sd.c id_us.c id_vh.c id_vl.c \
	   signon.c wl_act1.c wl_act2.c wl_agent.c wl_atmos.c wl_cloudsky.c \
	   wl_debug.c wl_draw.c wl_game.c wl_inter.c wl_main.c wl_menu.c \
	   wl_parallax.c wl_plane.c wl_play.c wl_scale.c wl_shade.c wl_state.c \
	   wl_text.c wl_utils.c dbopl.cpp n64_main.c

SOURCE_FILES := $(addprefix $(SOURCE_DIR)/,$(SOURCE_FILES))
C_SOURCES   := $(filter %.c,$(SOURCE_FILES))
CPP_SOURCES := $(filter %.cpp,$(SOURCE_FILES))

OBJECT_FILES := $(C_SOURCES:$(SOURCE_DIR)/%.c=$(BUILD_DIR)/%.o) \
                $(CPP_SOURCES:$(SOURCE_DIR)/%.cpp=$(BUILD_DIR)/%.o)

assets_conv := $(addprefix filesystem/$(GAME)/,$(assets))
assets := $(addprefix data/,$(assets))

all: $(ROMNAME).z64

filesystem/$(GAME)/%: data/%
	@mkdir -p $(dir $@)
	@echo "    [DATA] $@"
	@cp "$<" "$@"

$(BUILD_DIR)/$(ROMNAME).dfs: $(assets_conv)
$(BUILD_DIR)/$(ROMNAME).elf: $(OBJECT_FILES)

$(ROMNAME).z64: N64_ROM_TITLE=$(ROMTITLE)
$(ROMNAME).z64: N64_ROM_SAVETYPE=sram1m
$(ROMNAME).z64: N64_ROM_REGIONFREE=1
$(ROMNAME).z64: $(BUILD_DIR)/$(ROMNAME).dfs

clean:
	rm -rf $(BUILD_DIR) filesystem/ $(ROMNAME).z64

-include $(wildcard $(BUILD_DIR)/$(SOURCE_DIR)/*.d)

.PHONY: all clean
