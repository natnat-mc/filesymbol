return [[
#ifndef __FILESYMBOL_H
#define __FILESYMBOL_H

#include <stddef.h>

typedef struct filesymbol_t filesymbol_t;

typedef enum filesymbol_type_t {
	FILESYMBOL_FILE,
	FILESYMBOL_DIRECTORY
} filesymbol_type_t;

typedef void(*filesymbol_init_t)(filesymbol_t*);

struct filesymbol_t {
	union filesymbol_data_t {
		char* content;
		filesymbol_t* files;
	} data;
	filesymbol_type_t type;
	size_t length;
	char* name;
	filesymbol_init_t init;
};

#endif

static void filesymbol_noinit(filesymbol_t* none) {
	(void)(none);
}

]]
