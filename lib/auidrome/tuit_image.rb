# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  class TuitImage
    attr_reader :tuit
    attr_reader :quality

    def initialize(tuit, quality = 0)
      @tuit = tuit
      @quality = quality
    end

    def self.has_avatar?(auido)
      !image_of_quality(auido, 0).nil?
    end

    def self.has_images?(auido)
      !image_of_quality(auido, 1).nil?
    end

    def has_avatar?
      !TuitImage.has_avatar?(@tuit.hash[:filename], 0).nil?
    end

    def src
      if @tuit.auido and file?
        @file
      else
        "/images/common/#{@tuit.config.dromename}.png"
      end
    end

    def class
      quality == 0 ? 'img-thumbnail' : 'img-normal'
    end

    def better_image?
      !(image_of_quality(quality+1)).nil?
    end

    def quality
      @quality ||= 0
    end

    def href
      if better_image?
        "/tuits" + "/better" * (quality + 1) + "/#{@tuit.auido}"
      else
        "/tuits/#{@tuit.auido}"
      end
    end

    private
    def file?
      @file ||= image_of_quality(quality) || TuitImage.image_of_quality(@tuit.auido)
      !@file.nil?
    end

    def image_of_quality quality
      TuitImage.image_of_quality @tuit.hash[:filename], quality
    end

    def self.image_of_quality filename, quality = 0
      prefix = quality > 0 ? "#{(['better']*quality).join('/')}/" : ""
      basepath = "/images/#{prefix}#{filename}"
      %w{gif jpeg jpg png}.each do |extension|
        filepath = "#{basepath}.#{extension}"
        return filepath if File.exists?("public" + filepath)
      end
      return nil
    end

  end
end
