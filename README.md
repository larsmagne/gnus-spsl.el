This is a minor mode for Gnus to add "fancy" spam splitting mail
rules.

To use it, put the following in your ~/.gnus.el file:

```
(push "~/src/gnus-spsl.el/" load-path)
(require 'gnus-spsl)
(add-hook 'gnus-summary-mode-hook 'gnus-spam-split-activate)
```

This will enable two commands in summary buffers of mail groups:

z: Use the From/Subject of the current article to split as spam.
Z: Edit the list of spammy headers.

Then, for this to work, you have to be using "fancy" split rules, and
you need to add the following to somewhere near the start of your
rules:

```
(setq
 nnmail-split-fancy
 '(| (: gnus-spam-split)
     (from "foo.bar" "something")
	 ...
```

This functional rule will then output a split that corresponds to the
From/Subjects you've marked as being spammy.

The spammy messages will end up in `gnus-spam-split-group'.
