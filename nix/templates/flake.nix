{
  outputs = { self }: {
    templates.dev-php = {
      path = ./dev-php;
      description = "Latest available PHP + composer";
      welcomeText = ''
        # PHP Dev Environment
        Run `nix develop` to start.
      '';
    };
    
    templates.dev-node = {
      path = ./dev-node;
      description = "Node.js 20 environment";
    };
    
    templates.default = self.templates.dev-php;
  };
}
