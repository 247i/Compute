          f = figure;
          uimenu (f, "label", "&File", "accelerator", "f");
          uimenu (f, "label", "&Edit", "accelerator", "e");
          uimenu (f, "label", "Close", "accelerator", "q", ...
                     "callback", "close (gcf)");
          uimenu (e, "label", "Toggle &Grid", "accelerator", "g", ...
                     "callback", "grid (gca)");


          p = uipanel ("title", "StimFit", "position", [.25 .25 .5 .5]);

          ## add two buttons to the panel
          b1 = uicontrol ("parent", p, "string", "A Button", ...
                          "position", [18 10 150 36]);
          b2 = uicontrol ("parent", p, "string", "Another Button", ...
                          "position",[18 60 150 36]);



