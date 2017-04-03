/*
** mrb_gem.c - gem class
**
** Copyright (c) Nazarii Sheremet 2017
**
** See Copyright Notice in LICENSE
*/

#include "mruby.h"
#include "mruby/data.h"
#include "mrb_gem.h"

#define DONE mrb_gc_arena_restore(mrb, 0);

typedef struct {
  char *str;
  int len;
} mrb_gem_data;

static const struct mrb_data_type mrb_gem_data_type = {
  "mrb_gem_data", mrb_free,
};

void mrb_mruby_smallhttp_gem_init(mrb_state *mrb)
{
  struct RClass *gem;
  gem = mrb_define_class(mrb, "HTTP", mrb->object_class);
  DONE;
}

void mrb_mruby_smallhttp_gem_final(mrb_state *mrb)
{
}
