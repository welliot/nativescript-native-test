/*
In NativeScript, a file with the same name as an XML file is known as
a code-behind file. The code-behind is a great place to place your view
logic, and to set up your page’s data binding.
*/

const HomeViewModel = require("./home-view-model");
//const NativeAnimator = require("../NativeAnimator");

function onNavigatingTo(args) {
    const page = args.object;
    page.bindingContext = new HomeViewModel();

    page.ios.playerView = UIView.alloc().initWithFrame(CGRectMake(100, 500, 100, 100));
    page.ios.playerView.backgroundColor = UIColor.blackColor;
    page.ios.view.addSubview(page.ios.playerView);
    page.ios.animator = NativeAnimator.alloc().initWithViewAndParent(page.ios.playerView, page.ios.view);
    page.ios.animator.setup();
}

exports.onNavigatingTo = onNavigatingTo;
