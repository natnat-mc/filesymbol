return {

include = [[
#include <stddef.h>
]],

header = [[
#ifndef __FILESYMBOL_H
#define __FILESYMBOL_H

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
]],

helper = [[
#ifndef __FILESYMBOL_HELPER_H
#define __FILESYMBOL_HELPER_H

static void filesymbol_noinit(filesymbol_t* none) {
	(void)(none);
}

#endif
]],

}
