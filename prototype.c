#include <stdio.h>
#include "allegro5/allegro.h"

#define SIZE 512
#define MAX_ITER 200

int initialization() {
    if (!al_init()) {
        printf("Initialization error.\n");
        return 1;
    }

    if (!al_install_keyboard()) {
        printf("Keyboard initialization error.\n");
        return 1;
    }

    if (!al_install_mouse()) {
        printf("Keyboard initialization error.\n");
        return 1;
    }

    return 0;
}


void destroy(ALLEGRO_EVENT_QUEUE* queue, ALLEGRO_BITMAP* bitmap, ALLEGRO_DISPLAY* display) {
    al_destroy_event_queue(queue);
    al_destroy_bitmap(bitmap);
    al_destroy_display(display);
}


void mandel(unsigned *bitmap_ptr, int size, double delta, double x, double y) {
  double origx = x;
  double oldx, oldy;
  double tempx, tempy;
  int k = 0;
  for (int i = 0; i < size; ++i) {
    for (int j = 0; j < size; ++j) {
      oldx = oldy = tempx = tempy = 0;
      for (k=0 ;k < MAX_ITER; ++k) {
        oldx = tempx;
        oldy = tempy;
        tempx = x + (oldx*oldx) - (oldy*oldy);
        tempy = y + 2*(oldx*oldy);
        if ( (tempx*tempx + tempy*tempy) > (double)4)
          break;
      }
      if (k == MAX_ITER)
        *(bitmap_ptr+(i*size)+j) = 0x0000ff;
      else
        *(bitmap_ptr+(i*size)+j) = 0x000000;

      x+=delta;
    }
    x = origx;
    y += delta;
  }
}


void draw( ALLEGRO_BITMAP* bitmap, double scale, double x, double y ) {

    ALLEGRO_LOCKED_REGION *region =
      al_lock_bitmap(bitmap, ALLEGRO_PIXEL_FORMAT_ANY, ALLEGRO_LOCK_READWRITE);

    unsigned *data;
        data = (unsigned *) region->data;
    data += SIZE;
    data -= SIZE * SIZE;

    mandel(data, SIZE, scale, x, y);

    // Save changes and display modified bitmap
    al_unlock_bitmap(bitmap);
    al_clear_to_color(al_map_rgb(0, 0, 0));
    al_draw_bitmap(bitmap, 0, 0, 0);
    al_flip_display();
}


int main(int argc, char *argv[]) {

    ALLEGRO_DISPLAY* display;
    ALLEGRO_EVENT_QUEUE* queue;
    ALLEGRO_BITMAP* bitmap;

    if (initialization())
        return 1;

    // Creates window to display application
    display = al_create_display(SIZE, SIZE);
    if (!display) {
        printf("Display initialization error.\n");
        return 1;
    }

    // Creates queue for application key events
    queue = al_create_event_queue();
    if (!queue) {
        printf("Event queue initialization error.\n");
        return 1;
    }
    al_register_event_source( queue, al_get_keyboard_event_source() );
    al_register_event_source( queue, al_get_mouse_event_source() );

    // Creates bitmap to display in window application
    bitmap = al_create_bitmap( SIZE, SIZE );
    if (!bitmap) {
        printf("Bitmap load error.\n");
        return -1;
    }

    double scale = 3.0f/(double)SIZE;
    double x = -2.0f;
    double y = -1.5f;

    draw(bitmap, scale, x, y);

    while (true) {
        ALLEGRO_EVENT event;
        al_wait_for_event(queue, &event);
        if (event.type == ALLEGRO_EVENT_KEY_DOWN && event.keyboard.keycode == ALLEGRO_KEY_ESCAPE) {
            destroy(queue, bitmap, display);
            return 0;
        }

        if (event.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN) {
          x += (event.mouse.x)*scale;
          y += scale*SIZE;
          y -= (event.mouse.y)*scale;
          scale /= 1.5f;
          x -= scale * SIZE/2;
          y -= scale * SIZE/2;
          draw( bitmap, scale, x, y);
        }
    }
}

