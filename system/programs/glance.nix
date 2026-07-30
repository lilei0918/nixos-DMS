{
  services.glance = {
    enable = true;
    settings = {
      server = {
        host = "127.0.0.1";
        port = 8080;
      };

      pages = [
        {
          name = "Home";
          icon = "mdi:home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "rss";
                  title = "News";
                  limit = 30;
                  collapseAfter = 9;
                  feeds = [
                    {
                      url = "https://36kr.com/feed";
                      title = "36氪";
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Markets";
          icon = "mdi:chart-line";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "markets";
                  title = "Indices";
                  markets = [
                    {
                      symbol = "SPY";
                      name = "S&P 500";
                    }
                    {
                      symbol = "DX-Y.NYB";
                      name = "Dollar Index";
                    }
                  ];
                }
                {
                  type = "markets";
                  title = "Crypto";
                  markets = [
                    {
                      symbol = "BTC-USD";
                      name = "Bitcoin";
                    }
                    {
                      symbol = "ETH-USD";
                      name = "Ethereum";
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
