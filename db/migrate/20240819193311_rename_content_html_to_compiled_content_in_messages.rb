class RenameContentHtmlToCompiledContentInMessages < ActiveRecord::Migration[7.1]
  def change
    rename_column :messages, :content_html, :compiled_content
  end
end
