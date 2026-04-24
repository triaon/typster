defmodule Typster.FilesTest do
  use Typster.DataCase, async: true

  alias Typster.Files

  describe "file classification" do
    test "classifies editable file types" do
      assert Files.editable_file?("main.typ")
      assert Files.editable_file?("refs.bib")
      assert Files.typst_file?("main.typ")
      assert Files.bibtex_file?("refs.bib")
      assert Files.file_kind("main.typ") == :text
      assert Files.file_kind("refs.bib") == :text
      assert Files.editor_language("main.typ") == "typst"
      assert Files.editor_language("refs.bib") == "bibtex"
    end

    test "classifies asset and unknown file types" do
      assert Files.asset_file?("assets/logo.png")
      assert Files.asset_file?("assets/font.woff2")
      assert Files.file_kind("assets/logo.png") == :asset
      assert Files.file_kind("archive.bin") == :unknown
      refute Files.editable_file?("archive.bin")
    end
  end
end
