module Cms
  class Initializer
    Cms::Node.plugin "cms/node"
    Cms::Node.plugin "cms/page"
    Cms::Node.plugin "cms/import_node"
    Cms::Part.plugin "cms/free"
    Cms::Part.plugin "cms/node"
    Cms::Part.plugin "cms/page"
    Cms::Part.plugin "cms/tabs"
    Cms::Part.plugin "cms/crumb"
    Cms::Part.plugin "cms/sns_share"

    Cms::Role.permission :edit_cms_sites
    Cms::Role.permission :edit_cms_groups
    Cms::Role.permission :edit_cms_users
    Cms::Role.permission :edit_cms_roles
    Cms::Role.permission :edit_cms_members
    Cms::Role.permission :edit_cms_editor_templates
    #Cms::Role.permission :edit_cms_body_layouts
    Cms::Role.permission :use_cms_tools
    Cms::Role.permission :use_cms_editor_extensions
    Cms::Role.permission :read_other_cms_nodes
    Cms::Role.permission :read_other_cms_pages
    Cms::Role.permission :read_other_cms_parts
    Cms::Role.permission :read_other_cms_layouts
    Cms::Role.permission :read_other_cms_files
    Cms::Role.permission :read_other_cms_notices
    Cms::Role.permission :read_other_cms_page_searches
    Cms::Role.permission :read_private_cms_nodes
    Cms::Role.permission :read_private_cms_pages
    Cms::Role.permission :read_private_cms_parts
    Cms::Role.permission :read_private_cms_layouts
    Cms::Role.permission :read_private_cms_files
    Cms::Role.permission :read_private_cms_notices
    Cms::Role.permission :read_private_cms_page_searches
    Cms::Role.permission :edit_other_cms_nodes
    Cms::Role.permission :edit_other_cms_pages
    Cms::Role.permission :edit_other_cms_parts
    Cms::Role.permission :edit_other_cms_layouts
    Cms::Role.permission :edit_other_cms_files
    Cms::Role.permission :edit_other_cms_notices
    Cms::Role.permission :edit_other_cms_page_searches
    Cms::Role.permission :edit_private_cms_nodes
    Cms::Role.permission :edit_private_cms_pages
    Cms::Role.permission :edit_private_cms_parts
    Cms::Role.permission :edit_private_cms_layouts
    Cms::Role.permission :edit_private_cms_files
    Cms::Role.permission :edit_private_cms_notices
    Cms::Role.permission :edit_private_cms_page_searches
    Cms::Role.permission :delete_other_cms_nodes
    Cms::Role.permission :delete_other_cms_pages
    Cms::Role.permission :delete_other_cms_parts
    Cms::Role.permission :delete_other_cms_layouts
    Cms::Role.permission :delete_other_cms_files
    Cms::Role.permission :delete_other_cms_notices
    Cms::Role.permission :delete_other_cms_page_searches
    Cms::Role.permission :delete_private_cms_nodes
    Cms::Role.permission :delete_private_cms_pages
    Cms::Role.permission :delete_private_cms_parts
    Cms::Role.permission :delete_private_cms_layouts
    Cms::Role.permission :delete_private_cms_files
    Cms::Role.permission :delete_private_cms_notices
    Cms::Role.permission :delete_private_cms_page_searches
    Cms::Role.permission :release_other_cms_pages
    Cms::Role.permission :release_private_cms_pages
    Cms::Role.permission :approve_other_cms_pages
    Cms::Role.permission :approve_private_cms_pages
    Cms::Role.permission :move_private_cms_nodes
    Cms::Role.permission :move_private_cms_pages
    Cms::Role.permission :move_other_cms_nodes
    Cms::Role.permission :move_other_cms_pages
    Cms::Role.permission :unlock_other_cms_pages

    SS::File.model "cms/editor_template", SS::File
    SS::File.model "cms/file", Cms::File
    SS::File.model "cms/page", SS::File
  end
end
