project('uuidxx', ['cpp'], default_options: ['cpp_std=c++11'])

safe_args = ['-Wall', '-Weffc++', '-pedantic',
	'-pedantic-errors', '-Wextra',  '-Wall', '-Waggregate-return', '-Wcast-align',
	'-Wcast-qual',  '-Wchar-subscripts',  '-Wcomment', '-Wconversion',
	'-Wdisabled-optimization',
	'-Wfloat-equal',  '-Wformat',  '-Wformat=2',
	'-Wformat-nonliteral', '-Wformat-security',
	'-Wformat-y2k',
	'-Wimport',  '-Winit-self',  '-Winline',
	'-Winvalid-pch',
	'-Wlong-long', '-Wmissing-braces',
	'-Wno-missing-field-initializers', '-Wmissing-format-attribute',
	'-Wmissing-include-dirs', '-Wmissing-noreturn',
	'-Wpacked',  '-Wparentheses',  '-Wpointer-arith',
	'-Wredundant-decls', '-Wreturn-type',
	'-Wsequence-point',  '-Wshadow', '-Wsign-compare',  '-Wstack-protector',
	'-Wstrict-aliasing', '-Wstrict-aliasing=2', '-Wswitch',  '-Wswitch-default',
	'-Wswitch-enum', '-Wtrigraphs',  '-Wuninitialized',
	'-Wunknown-pragmas',  '-Wunreachable-code',
	'-Wunused-function',  '-Wunused-label', '-Wno-unused-parameter',
	'-Wunused-value',  '-Wunused-variable',  '-Wvariadic-macros',
	'-Wvolatile-register-var',  '-Wwrite-strings', '-Wfatal-errors',
	'-Wno-deprecated-declarations']

add_global_arguments(safe_args, language: ['cpp'])

uuidxx = shared_library('uuidxx', 'uuidxx.cpp', install: true)
static_library('uuidxx', 'uuidxx.cpp', install: true)

uudxxtest = executable('uuidxxtest', 'tests/main.cpp', link_with: uuidxx, install: false)

test('functionality test', uudxxtest)
