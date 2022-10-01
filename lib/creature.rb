require 'rmagick'
require 'rtesseract'

class Creature
  attr_reader :folder

  BIO_BOX = {
    x1: 627,
    y1: 120,
    width: 655,
    height: 615,
  }

  def initialize(folder:)
    @folder = folder
  end

  def name
    @name ||= self.folder.split("/").last
  end

  def page_one
    @page_one ||= File.read("#{self.folder}/1.png")
  end

  def page_two
    @page_two ||= File.read("#{self.folder}/2.png")
  end

  def bio_image_path
    "#{self.folder}/bio.png"
  end

  def bio_text_path
    "#{self.folder}/bio.txt"
  end

  def bio_image
    @bio_image ||= begin
      if File.file?(self.bio_image_path)
        File.read(self.bio_image_path)
      else
        bio_image = Magick::ImageList.new
        bio_image.from_blob(self.page_two)
        bio_image = bio_image.crop(BIO_BOX[:x1], BIO_BOX[:y1], BIO_BOX[:width], BIO_BOX[:height])
        bio_image = bio_image.negate
        bio_image.colorspace = Magick::GRAYColorspace
        bio_image_blob = bio_image.to_blob
        File.write(self.bio_image_path, bio_image_blob)
        bio_image_blob
      end
    end
  end

  def bio_text
    @bio_image_ocr ||= begin
      if File.file?(self.bio_text_path)
        File.read(self.bio_text_path)
      else
        self.bio_image
        bio_image_ocr = RTesseract.new(self.bio_image_path, lang: 'eng', oem: 1, psm: 4).to_s
        File.write(self.bio_text_path, bio_image_ocr)
        bio_image_ocr
      end
    end
  end
end