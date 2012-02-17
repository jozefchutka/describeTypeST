package sk.yoz.data.describeTypeST.demo
{
    import mx.collections.ICollectionView;
    import mx.controls.treeClasses.DefaultDataDescriptor;
    
    public dynamic class DataProxyDescriptor extends DefaultDataDescriptor
    {
        override public function getChildren(node:Object, model:Object=null):ICollectionView
        {
            var proxy:DataProxy = node as DataProxy;
            return proxy.hasChildren ? proxy.children : null;
        }
        
        override public function hasChildren(node:Object, model:Object=null):Boolean
        {
            return (node as DataProxy).hasChildren;
        }
        
        override public function isBranch(node:Object, model:Object=null):Boolean
        {
            var proxy:DataProxy = node as DataProxy;
            return proxy ? proxy.hasChildren : false;
        }
    }
}