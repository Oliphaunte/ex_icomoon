defmodule SideRail do
  use KuratorsAdmin, :live_component

  alias Kurators.Accounts.User

  def mount(socket) do
    links = [
      [%{patch: Routes.index_path(socket, :index), icon: "home", label: "Dashboard"}],
      [%{patch: Routes.users_path(socket, :index), icon: "users", label: "Users"}]
      # [%{patch: Routes.inventory_path(socket, :index), icon: "inventory", label: "Inventory"}]
      # [%{patch: Routes.support_path(socket, :index), icon: "wrench", label: "Support"}],
      # [
      #   %{patch: Routes.builder_path(socket, :index), icon: "hammer", label: "Builder"},
      #   %{patch: Routes.pages_path(socket, :index), icon: "file", label: "Pages"},
      #   %{patch: Routes.components_path(socket, :index), icon: "files", label: "Components"}
      # ],
      # [
      #   %{patch: Routes.devops_path(socket, :index), icon: "cogs", label: "Devops"},
      #   %{patch: Routes.devops_audit_trail_path(socket, :index), icon: "stats", label: "Audit"},
      #   %{patch: Routes.devops_logs_path(socket, :index), icon: "books", label: "Logs"},
      #   %{patch: Routes.devops_clusters_path(socket, :index), icon: "database", label: "Clusters"}
      # ]
    ]

    {:ok,
     socket
     |> assign(:links, links)}
  end
end
