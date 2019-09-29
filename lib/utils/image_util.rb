class ImageUtil
  class << self
    def convert_to_png(file_path)
      handle = RSVG::Handle.new_from_file(file_path)

      dim = handle.dimensions
      width = dim.width * 0.8
      height = dim.height * 0.8

      surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, width, height)
      context = Cairo::Context.new(surface)

      context.scale(0.8, 0.8)
      context.render_rsvg_handle(handle)

      surface.write_to_png(file_path.sub(/\.[^.]+$/i, '.png'))
    end
  end
end
