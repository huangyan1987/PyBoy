#
# License: See LICENSE.md file
# GitHub: https://github.com/Baekalfen/PyBoy
#
cimport cython
from cpython.array cimport array

cimport sdl2
cimport sdl2_ttf
cimport pyboy.plugins.window_sdl2
from pyboy.core.mb cimport Motherboard
from pyboy.botsupport.sprite cimport Sprite
from pyboy.botsupport.tilemap cimport TileMap
from pyboy.plugins.base_plugin cimport PyBoyWindowPlugin
from pyboy.utils cimport WindowEvent

from libc.stdint cimport uint8_t, uint16_t, uint32_t, uint64_t, int64_t

cdef uint32_t COLOR
cdef uint32_t MASK
cdef uint32_t HOVER
cdef int mark_counter
cdef set marked_tiles
cdef uint32_t[:] MARK


cdef class MarkedTile:
    cdef public int tile_identifier
    cdef str mark_id
    cdef public uint32_t mark_color
    cdef int sprite_height


cdef class Debug(PyBoyWindowPlugin):
    cdef TileViewWindow tile1
    cdef TileViewWindow tile2
    cdef SpriteViewWindow spriteview
    cdef SpriteWindow sprite
    cdef TileDataWindow tiledata
    cdef bint sdl2_event_pump


cdef class BaseDebugWindow(PyBoyWindowPlugin):
    cdef int width
    cdef int height
    cdef int hover_x
    cdef int hover_y
    cdef str base_title
    cdef int window_id

    cdef sdl2.SDL_Window *_window
    cdef sdl2.SDL_Renderer *_sdlrenderer
    cdef sdl2.SDL_Texture *_sdltexturebuffer
    cdef array buf
    cdef uint32_t[:,:] buf0
    cdef object buf_p

    @cython.locals(y=int, x=int)
    cdef void copy_tile(self, uint32_t[:,:], int, int, int, uint32_t[:,:])

    @cython.locals(i=int, tw=int, th=int, xx=int, yy=int)
    cdef void mark_tile(self, int, int, uint32_t, int, int, bint)

    cdef inline void _update_display(self):
        sdl2.SDL_UpdateTexture(self._sdltexturebuffer, NULL, self.buf.data.as_voidptr, self.width*4)
        sdl2.SDL_RenderCopy(self._sdlrenderer, self._sdltexturebuffer, NULL, NULL)
        sdl2.SDL_RenderPresent(self._sdlrenderer)

    @cython.locals(event=WindowEvent)
    cdef list handle_events(self, list)

cdef class TileViewWindow(BaseDebugWindow):
    cdef int scanline_x
    cdef int scanline_y
    cdef TileMap tilemap
    cdef uint32_t color

    @cython.locals(mem_offset=uint16_t, tile_index=int, tile_column=int, tile_row=int)
    cdef void post_tick(self)

    # scanlineparameters=uint8_t[:,:],
    @cython.locals(x=int, y=int, xx=int, yy=int, row=int, column=int)
    cdef void draw_overlay(self)


cdef class TileDataWindow(BaseDebugWindow):
    @cython.locals(t=int, xx=int, yy=int)
    cdef void post_tick(self)

    @cython.locals(tile_x=int, tile_y=int, tile_identifier=int)
    cdef list handle_events(self, list)

    @cython.locals(t=MarkedTile, column=int, row=int)
    cdef void draw_overlay(self)


cdef class SpriteWindow(BaseDebugWindow):
    @cython.locals(tile_x=int, tile_y=int, sprite_identifier=int, sprite=Sprite)
    cdef list handle_events(self, list)

    @cython.locals(t=MarkedTile, xx=int, yy=int, sprite=Sprite, i=int)
    cdef void draw_overlay(self)

    @cython.locals(title=str)
    cdef void update_title(self)

cdef class SpriteViewWindow(BaseDebugWindow):
    @cython.locals(t=int, x=int, y=int)
    cdef void post_tick(self)

    @cython.locals(t=MarkedTile, sprite=Sprite, i=int)
    cdef void draw_overlay(self)

    @cython.locals(title=str)
    cdef void update_title(self)

cdef class MemoryWindow(BaseDebugWindow):
    cdef int start_address
    cdef int end_address
    cdef str font_path
    cdef int font_size

    cdef sdl2_ttf.TTF_Font* font
    cdef sdl2.SDL_Texture *texture
    cdef sdl2.SDL_Rect* destination
    cdef sdl2.SDL_Surface* surface

    cdef str memory_row(self, int, int)
    cdef void header(self)
    cdef void body(self)
    cdef void footer(self)
    # @cython.locals(w=p_int, h=p_int)
    @cython.locals(w=int, h=int)
    cdef void get_destination(self)
