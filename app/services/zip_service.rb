# frozen_string_literal: true
require 'fileutils'
require 'zip'

# Abstracting out our zipping/unzipping into its own service so that it's not
# lumped in with another one.
#
# Note: when zipping a file, be sure to include a file extension, as the {#zip!}
# method will write to wherever is passed as +dest_path+.
#
# @example Unzipping an item
#   service = ZipService.new(src_path: '/path/to/file.zip')
#   service.unzip!(dest_path: '/path/to/new/home')
#
# @example Zipping a directory
#   service = ZipService.new(src_path: '/path/to/directory')
#   service.zip!(dest_path: '/path/to/directory.zip')
#
# @example Zipping a single file
#   service = ZipService.new(src_path: '/path/to/file.jpg')
#   service.zip!(dest_path: '/path/to/file.zip')
#
# @todo add support for +src_path+ to be an array of paths?
# @todo add logging support?
class ZipService
  attr_reader :src_path

  # @param [String, Pathname] src_path
  def initialize(src_path:)
    @src_path = src_path
  end

  # unzips the contents of +@src_path+ to +dest_path+
  #
  # @param [String, Pathname] dest_path
  # @return [void]
  def unzip!(dest_path:)
    FileUtils.mkdir_p(dest_path)

    ::Zip::File.open(src_path) do |zip_file|
      zip_file.each do |entry|
        entry.extract(File.join(dest_path, entry.name))
      end
    end
  end

  # writes the contents of +@src_path+ to a zip file at +dest_path+
  #
  # @param [String, Pathname] dest_path Destination path (should contain '.zip')
  # @return [Zip::File]
  def zip!(dest_path:)
    ::Zip::File.open(dest_path, ::Zip::File::CREATE) do |zipfile|
      write_entries(entries, '', zipfile)
    end
  end

  private

  # Entries returned from +Dir.entries(path)+ that we want to exclude
  #
  # @return [Array<String>]
  def blacklisted_dir_entries
    %w[. ..]
  end

  # @return [Array<String>]
  def entries
    return [File.basename(src_path)] unless File.directory?(src_path)
    Dir.entries(src_path) - blacklisted_dir_entries
  end

  # Writes an array of file entries (files or directories) to a Zip::File
  #
  # Copied from the rubyzip readme:
  # https://github.com/rubyzip/rubyzip/blob/a27204f/README.md#zipping-a-directory-recursively
  #
  # @param [Array<String>] entries Things to zip up
  # @param [String] path Relative path of entries
  # @param [Zip::File] zipfile Zip to write to
  def write_entries(entries, path, zipfile)
    entries.each do |entry|
      zipfile_path = path == '' ? entry : File.join(path, entry)
      disk_file_path = File.join(src_path, zipfile_path)

      if File.directory?(disk_file_path)
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  # If we've hit a directory, this will create a matching one in the
  # zipfile and recursively write the entries of the directory to it.
  #
  # Copied from the rubyzip readme:
  # https://github.com/rubyzip/rubyzip/blob/a27204f/README.md#zipping-a-directory-recursively
  #
  # @param [String] disk_file_path The directory we want to deflate
  # @param [Zip::File] zipfile The Zip::File we're writing to
  # @param [String] zipfile_path where in the zip file we're writing to
  # @return [void]
  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir(zipfile_path)
    subdir = Dir.entries(disk_file_path) - blacklisted_dir_entries
    write_entries(subdir, zipfile_path, zipfile)
  end

  # Writes an item into the zip archive
  #
  # Copied from the rubyzip readme:
  # https://github.com/rubyzip/rubyzip/blob/a27204f/README.md#zipping-a-directory-recursively
  #
  # @param [String] disk_file_path The file we want to deflate
  # @param [Zip::File] zipfile The Zip::File we're writing to
  # @param [String] zipfile_path where in the zip file we're writing to
  # @return [void]
  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.get_output_stream(zipfile_path) do |f|
      f.write(File.open(disk_file_path, 'rb').read)
    end
  end
end
