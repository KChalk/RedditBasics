��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clm
ProductionPhonClassifier
qXE   /mnt/c/Users/kdcha/Documents/Winter19/RedditProject/TsneProject/lm.pyqX4  class ProductionPhonClassifier(nn.Module):
    def __init__(self, input_vocab_size, n_embedding_dims, n_hidden_dims, n_lstm_layers, output_class_size, pretrained_embedding):
      
        super(ProductionPhonClassifier, self).__init__()
        self.lstm_dims = n_hidden_dims
        self.lstm_layers = n_lstm_layers

        self.input_lookup = nn.Embedding(num_embeddings=input_vocab_size, embedding_dim=n_embedding_dims)
        self.lstm = nn.LSTM(input_size=n_embedding_dims, hidden_size=n_hidden_dims, num_layers=n_lstm_layers, batch_first=True, bidirectional=False)
        self.linear = nn.Linear(in_features=n_hidden_dims*2, out_features=n_hidden_dims)
        self.output = nn.Linear(in_features=n_hidden_dims, out_features=output_class_size)
        self.softmax = nn.LogSoftmax(dim=1)

        self.input_lookup.from_pretrained(pretrained_embedding, freeze=False)

    def forward(self, history_tensor_p,history_tensor_t, prev_hidden_state):
        """
        Given a history, and a previous timepoint's hidden state, predict 

        """     
        embed_p = self.input_lookup(history_tensor_p) 
        embed_t = self.input_lookup(history_tensor_t)

        lstm_p, h_p = self.lstm(embed_p)
        lstm_t, h_t = self.lstm(embed_t)

        last_out_p = lstm_p[:,-1,:] 
        last_out_t = lstm_t[:,-1,:] 

        linear_in= torch.cat((last_out_p,last_out_t), 1)

        linear_out=self.linear(linear_in)
        out = self.output(linear_out)
        out = self.softmax(out)

        return out, (h_p, h_t)
        
    def init_hidden(self):
        """
        Generate a blank initial history value, for use when we start predicting over a fresh sequence.
        """
        h_0 = torch.randn(self.lstm_layers, 1, self.lstm_dims)
        c_0 = torch.randn(self.lstm_layers, 1, self.lstm_dims)
        return(h_0,c_0)
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _modulesqh)Rq(X   input_lookupq(h ctorch.nn.modules.sparse
Embedding
qXM   /home/kchalk/anaconda3/lib/python3.6/site-packages/torch/nn/modules/sparse.pyqX?  class Embedding(Module):
    r"""A simple lookup table that stores embeddings of a fixed dictionary and size.

    This module is often used to store word embeddings and retrieve them using indices.
    The input to the module is a list of indices, and the output is the corresponding
    word embeddings.

    Args:
        num_embeddings (int): size of the dictionary of embeddings
        embedding_dim (int): the size of each embedding vector
        padding_idx (int, optional): If given, pads the output with the embedding vector at :attr:`padding_idx`
                                         (initialized to zeros) whenever it encounters the index.
        max_norm (float, optional): If given, will renormalize the embedding vectors to have a norm lesser than
                                    this before extracting.
        norm_type (float, optional): The p of the p-norm to compute for the max_norm option. Default ``2``.
        scale_grad_by_freq (boolean, optional): if given, this will scale gradients by the inverse of frequency of
                                                the words in the mini-batch. Default ``False``.
        sparse (bool, optional): if ``True``, gradient w.r.t. :attr:`weight` matrix will be a sparse tensor.
                                 See Notes for more details regarding sparse gradients.

    Attributes:
        weight (Tensor): the learnable weights of the module of shape (num_embeddings, embedding_dim)

    Shape:

        - Input: LongTensor of arbitrary shape containing the indices to extract
        - Output: `(*, embedding_dim)`, where `*` is the input shape

    .. note::
        Keep in mind that only a limited number of optimizers support
        sparse gradients: currently it's :class:`optim.SGD` (`CUDA` and `CPU`),
        :class:`optim.SparseAdam` (`CUDA` and `CPU`) and :class:`optim.Adagrad` (`CPU`)

    .. note::
        With :attr:`padding_idx` set, the embedding vector at
        :attr:`padding_idx` is initialized to all zeros. However, note that this
        vector can be modified afterwards, e.g., using a customized
        initialization method, and thus changing the vector used to pad the
        output. The gradient for this vector from :class:`~torch.nn.Embedding`
        is always zero.

    Examples::

        >>> # an Embedding module containing 10 tensors of size 3
        >>> embedding = nn.Embedding(10, 3)
        >>> # a batch of 2 samples of 4 indices each
        >>> input = torch.LongTensor([[1,2,4,5],[4,3,2,9]])
        >>> embedding(input)
        tensor([[[-0.0251, -1.6902,  0.7172],
                 [-0.6431,  0.0748,  0.6969],
                 [ 1.4970,  1.3448, -0.9685],
                 [-0.3677, -2.7265, -0.1685]],

                [[ 1.4970,  1.3448, -0.9685],
                 [ 0.4362, -0.4004,  0.9400],
                 [-0.6431,  0.0748,  0.6969],
                 [ 0.9124, -2.3616,  1.1151]]])


        >>> # example with padding_idx
        >>> embedding = nn.Embedding(10, 3, padding_idx=0)
        >>> input = torch.LongTensor([[0,2,0,5]])
        >>> embedding(input)
        tensor([[[ 0.0000,  0.0000,  0.0000],
                 [ 0.1535, -2.0309,  0.9315],
                 [ 0.0000,  0.0000,  0.0000],
                 [-0.1655,  0.9897,  0.0635]]])
    """

    def __init__(self, num_embeddings, embedding_dim, padding_idx=None,
                 max_norm=None, norm_type=2, scale_grad_by_freq=False,
                 sparse=False, _weight=None):
        super(Embedding, self).__init__()
        self.num_embeddings = num_embeddings
        self.embedding_dim = embedding_dim
        if padding_idx is not None:
            if padding_idx > 0:
                assert padding_idx < self.num_embeddings, 'Padding_idx must be within num_embeddings'
            elif padding_idx < 0:
                assert padding_idx >= -self.num_embeddings, 'Padding_idx must be within num_embeddings'
                padding_idx = self.num_embeddings + padding_idx
        self.padding_idx = padding_idx
        self.max_norm = max_norm
        self.norm_type = norm_type
        self.scale_grad_by_freq = scale_grad_by_freq
        if _weight is None:
            self.weight = Parameter(torch.Tensor(num_embeddings, embedding_dim))
            self.reset_parameters()
        else:
            assert list(_weight.shape) == [num_embeddings, embedding_dim], \
                'Shape of weight does not match num_embeddings and embedding_dim'
            self.weight = Parameter(_weight)
        self.sparse = sparse

    def reset_parameters(self):
        self.weight.data.normal_(0, 1)
        if self.padding_idx is not None:
            self.weight.data[self.padding_idx].fill_(0)

    def forward(self, input):
        return F.embedding(
            input, self.weight, self.padding_idx, self.max_norm,
            self.norm_type, self.scale_grad_by_freq, self.sparse)

    def extra_repr(self):
        s = '{num_embeddings}, {embedding_dim}'
        if self.padding_idx is not None:
            s += ', padding_idx={padding_idx}'
        if self.max_norm is not None:
            s += ', max_norm={max_norm}'
        if self.norm_type != 2:
            s += ', norm_type={norm_type}'
        if self.scale_grad_by_freq is not False:
            s += ', scale_grad_by_freq={scale_grad_by_freq}'
        if self.sparse is not False:
            s += ', sparse=True'
        return s.format(**self.__dict__)

    @classmethod
    def from_pretrained(cls, embeddings, freeze=True, sparse=False):
        r"""Creates Embedding instance from given 2-dimensional FloatTensor.

        Args:
            embeddings (Tensor): FloatTensor containing weights for the Embedding.
                First dimension is being passed to Embedding as 'num_embeddings', second as 'embedding_dim'.
            freeze (boolean, optional): If ``True``, the tensor does not get updated in the learning process.
                Equivalent to ``embedding.weight.requires_grad = False``. Default: ``True``
            sparse (bool, optional): if ``True``, gradient w.r.t. weight matrix will be a sparse tensor.
                See Notes for more details regarding sparse gradients.

        Examples::

            >>> # FloatTensor containing pretrained weights
            >>> weight = torch.FloatTensor([[1, 2.3, 3], [4, 5.1, 6.3]])
            >>> embedding = nn.Embedding.from_pretrained(weight)
            >>> # Get embeddings for index 1
            >>> input = torch.LongTensor([1])
            >>> embedding(input)
            tensor([[ 4.0000,  5.1000,  6.3000]])
        """
        assert embeddings.dim() == 2, \
            'Embeddings parameter is expected to be 2-dimensional'
        rows, cols = embeddings.shape
        embedding = cls(
            num_embeddings=rows,
            embedding_dim=cols,
            _weight=embeddings,
            sparse=sparse,
        )
        embedding.weight.requires_grad = not freeze
        return embedding
qtqQ)�q}q(hh	h
h)RqX   weightqctorch.nn.parameter
Parameter
q ctorch._utils
_rebuild_tensor_v2
q!((X   storageq"ctorch
FloatStorage
q#X   140736408791920q$X   cpuq%M�
Ntq&QK KUK �q'K K�q(�Ntq)Rq*��q+Rq,shh)Rq-hh)Rq.hh)Rq/hh)Rq0hh)Rq1X   trainingq2�X   num_embeddingsq3KUX   embedding_dimq4K X   padding_idxq5NX   max_normq6NX	   norm_typeq7KX   scale_grad_by_freqq8�X   sparseq9�ubX   lstmq:(h ctorch.nn.modules.rnn
LSTM
q;XJ   /home/kchalk/anaconda3/lib/python3.6/site-packages/torch/nn/modules/rnn.pyq<X0  class LSTM(RNNBase):
    r"""Applies a multi-layer long short-term memory (LSTM) RNN to an input
    sequence.


    For each element in the input sequence, each layer computes the following
    function:

    .. math::

            \begin{array}{ll}
            i_t = \sigma(W_{ii} x_t + b_{ii} + W_{hi} h_{(t-1)} + b_{hi}) \\
            f_t = \sigma(W_{if} x_t + b_{if} + W_{hf} h_{(t-1)} + b_{hf}) \\
            g_t = \tanh(W_{ig} x_t + b_{ig} + W_{hg} h_{(t-1)} + b_{hg}) \\
            o_t = \sigma(W_{io} x_t + b_{io} + W_{ho} h_{(t-1)} + b_{ho}) \\
            c_t = f_t c_{(t-1)} + i_t g_t \\
            h_t = o_t \tanh(c_t)
            \end{array}

    where :math:`h_t` is the hidden state at time `t`, :math:`c_t` is the cell
    state at time `t`, :math:`x_t` is the input at time `t`, :math:`h_{(t-1)}`
    is the hidden state of the previous layer at time `t-1` or the initial hidden
    state at time `0`, and :math:`i_t`, :math:`f_t`, :math:`g_t`,
    :math:`o_t` are the input, forget, cell, and output gates, respectively.
    :math:`\sigma` is the sigmoid function.

    Args:
        input_size: The number of expected features in the input `x`
        hidden_size: The number of features in the hidden state `h`
        num_layers: Number of recurrent layers. E.g., setting ``num_layers=2``
            would mean stacking two LSTMs together to form a `stacked LSTM`,
            with the second LSTM taking in outputs of the first LSTM and
            computing the final results. Default: 1
        bias: If ``False``, then the layer does not use bias weights `b_ih` and `b_hh`.
            Default: ``True``
        batch_first: If ``True``, then the input and output tensors are provided
            as (batch, seq, feature). Default: ``False``
        dropout: If non-zero, introduces a `Dropout` layer on the outputs of each
            LSTM layer except the last layer, with dropout probability equal to
            :attr:`dropout`. Default: 0
        bidirectional: If ``True``, becomes a bidirectional LSTM. Default: ``False``

    Inputs: input, (h_0, c_0)
        - **input** of shape `(seq_len, batch, input_size)`: tensor containing the features
          of the input sequence.
          The input can also be a packed variable length sequence.
          See :func:`torch.nn.utils.rnn.pack_padded_sequence` or
          :func:`torch.nn.utils.rnn.pack_sequence` for details.
        - **h_0** of shape `(num_layers * num_directions, batch, hidden_size)`: tensor
          containing the initial hidden state for each element in the batch.
        - **c_0** of shape `(num_layers * num_directions, batch, hidden_size)`: tensor
          containing the initial cell state for each element in the batch.

          If `(h_0, c_0)` is not provided, both **h_0** and **c_0** default to zero.


    Outputs: output, (h_n, c_n)
        - **output** of shape `(seq_len, batch, num_directions * hidden_size)`: tensor
          containing the output features `(h_t)` from the last layer of the LSTM,
          for each t. If a :class:`torch.nn.utils.rnn.PackedSequence` has been
          given as the input, the output will also be a packed sequence.

          For the unpacked case, the directions can be separated
          using ``output.view(seq_len, batch, num_directions, hidden_size)``,
          with forward and backward being direction `0` and `1` respectively.
          Similarly, the directions can be separated in the packed case.
        - **h_n** of shape `(num_layers * num_directions, batch, hidden_size)`: tensor
          containing the hidden state for `t = seq_len`.

          Like *output*, the layers can be separated using
          ``h_n.view(num_layers, num_directions, batch, hidden_size)`` and similarly for *c_n*.
        - **c_n** (num_layers * num_directions, batch, hidden_size): tensor
          containing the cell state for `t = seq_len`

    Attributes:
        weight_ih_l[k] : the learnable input-hidden weights of the :math:`\text{k}^{th}` layer
            `(W_ii|W_if|W_ig|W_io)`, of shape `(4*hidden_size x input_size)`
        weight_hh_l[k] : the learnable hidden-hidden weights of the :math:`\text{k}^{th}` layer
            `(W_hi|W_hf|W_hg|W_ho)`, of shape `(4*hidden_size x hidden_size)`
        bias_ih_l[k] : the learnable input-hidden bias of the :math:`\text{k}^{th}` layer
            `(b_ii|b_if|b_ig|b_io)`, of shape `(4*hidden_size)`
        bias_hh_l[k] : the learnable hidden-hidden bias of the :math:`\text{k}^{th}` layer
            `(b_hi|b_hf|b_hg|b_ho)`, of shape `(4*hidden_size)`

    Examples::

        >>> rnn = nn.LSTM(10, 20, 2)
        >>> input = torch.randn(5, 3, 10)
        >>> h0 = torch.randn(2, 3, 20)
        >>> c0 = torch.randn(2, 3, 20)
        >>> output, (hn, cn) = rnn(input, (h0, c0))
    """

    def __init__(self, *args, **kwargs):
        super(LSTM, self).__init__('LSTM', *args, **kwargs)
q=tq>Q)�q?}q@(hh	h
h)RqA(X   weight_ih_l0qBh h!((h"h#X   140736424181328qCh%M 
NtqDQK KPK �qEK K�qF�NtqGRqH��qIRqJX   weight_hh_l0qKh h!((h"h#X   140736421848848qLh%M@NtqMQK KPK�qNKK�qO�NtqPRqQ��qRRqSX
   bias_ih_l0qTh h!((h"h#X   140736421848144qUh%KPNtqVQK KP�qWK�qX�NtqYRqZ��q[Rq\X
   bias_hh_l0q]h h!((h"h#X   140736424174512q^h%KPNtq_QK KP�q`K�qa�NtqbRqc��qdRqeuhh)Rqfhh)Rqghh)Rqhhh)Rqihh)Rqjh2�X   modeqkX   LSTMqlX
   input_sizeqmK X   hidden_sizeqnKX
   num_layersqoKX   biasqp�X   batch_firstqq�X   dropoutqrK X   dropout_stateqs}qtX   bidirectionalqu�X   _all_weightsqv]qw]qx(hBhKhTh]eaX
   _data_ptrsqy]qzubX   linearq{(h ctorch.nn.modules.linear
Linear
q|XM   /home/kchalk/anaconda3/lib/python3.6/site-packages/torch/nn/modules/linear.pyq}X%  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, in\_features)` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, out\_features)` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            `(out_features x in_features)`
        bias:   the learnable bias of the module of shape `(out_features)`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
    """

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        stdv = 1. / math.sqrt(self.weight.size(1))
        self.weight.data.uniform_(-stdv, stdv)
        if self.bias is not None:
            self.bias.data.uniform_(-stdv, stdv)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q~tqQ)�q�}q�(hh	h
h)Rq�(hh h!((h"h#X   140736424225328q�h%M Ntq�QK KK(�q�K(K�q��Ntq�Rq���q�Rq�hph h!((h"h#X   140736418397744q�h%KNtq�QK K�q�K�q��Ntq�Rq���q�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�h2�X   in_featuresq�K(X   out_featuresq�KubX   outputq�h|)�q�}q�(hh	h
h)Rq�(hh h!((h"h#X   140736418385792q�h%K(Ntq�QK KK�q�KK�q��Ntq�Rq���q�Rq�hph h!((h"h#X   140736424177296q�h%KNtq�QK K�q�K�q��Ntq�Rq���q�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�h2�h�Kh�KubX   softmaxq�(h ctorch.nn.modules.activation
LogSoftmax
q�XQ   /home/kchalk/anaconda3/lib/python3.6/site-packages/torch/nn/modules/activation.pyq�X  class LogSoftmax(Module):
    r"""Applies the `Log(Softmax(x))` function to an n-dimensional input Tensor.
    The LogSoftmax formulation can be simplified as

    :math:`\text{LogSoftmax}(x_{i}) = \log\left(\frac{\exp(x_i) }{ \sum_j \exp(x_j)} \right)`

    Shape:
        - Input: any shape
        - Output: same as input

    Arguments:
        dim (int): A dimension along which Softmax will be computed (so every slice
            along dim will sum to 1).

    Returns:
        a Tensor of the same dimension and shape as the input with
        values in the range [-inf, 0)

    Examples::

        >>> m = nn.LogSoftmax()
        >>> input = torch.randn(2, 3)
        >>> output = m(input)
    """

    def __init__(self, dim=None):
        super(LogSoftmax, self).__init__()
        self.dim = dim

    def __setstate__(self, state):
        self.__dict__.update(state)
        if not hasattr(self, 'dim'):
            self.dim = None

    def forward(self, input):
        return F.log_softmax(input, self.dim, _stacklevel=5)
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�h2�X   dimq�Kubuh2�X	   lstm_dimsq�KX   lstm_layersq�Kub.�]q (X   140736408791920qX   140736418385792qX   140736418397744qX   140736421848144qX   140736421848848qX   140736424174512qX   140736424177296qX   140736424181328qX   140736424225328q	e.�
      λ>�M�?��/?�m�<��Կ�Y���w?%I?�w?�9��N����>�LT��`�=.�A?�p˾6���i"'�x�H�J�"?�L���������o��2?a�f�Op�>�r>>V�?0��}⿇��?ܚ�@��"^>����M�a�w������@5�l�����Eۘ>�L@*����콙�վ��˾.V�?�mQ��Q�e�P�Av�\� ���3�u��>��<q}k��㬿�>�߾���?i����$>m�?�����?��?o��>: �ھ.�fqҿN��>���9@?����NQ>Zp%?�@��:IH?;)����X�d2���C?�]���4���@_t��� ?��V?y`��',3��ep?�h��:�I���>���?��E���~���ń`�Ǝ�=�vJ?��Z���>6�?j�𾷞t>Naf�R���?���?)���Z�?�
@qN��!k?iO�>.��>OT?���?D�?o��?]�?������̾^k�J���P�:?��@�Y>�ã>��K�Sװ?����j?�'��� ��`���b?���>?�;���̿�>?������8?��?�?��6�Zץ>XV�v�?ޜ�I����R�>����� ?@��հ@?�-?i[�=��6� �q�'��?�K���>e��]g�j�>�?vvW>��=J�&>|%@nCP�zᇾ�@�t^�?y�ɾ��?���N�q��?D�p?H.l�{}�?ҶýFp)��p�����i�>��WX�>��?J�?����V?n�!?�se�nA"�g��>��w�-D@?�?�q�ZN�Pӛ��~?�K���:?>F[=�Ѹ��I�Zz7?p?��#���?�� ?ӴO��W��*C����ʿS�=Dv���D�ܤ��e��Jn�	A��
??��zc��>�6>��<N��>���ʺ=�\�>��?�&��Tf�?���?̷I�Iy���*��oH��Z?�a��ss�?ᑖ�n��?�KĿ���>,���8�>k�Ϳ����Ʊ�u�P?�� ��������͜>��ɿ\Q�Ҍ-�p>K�4w��T*��9�?%L�i<��D����R�ȿ�?H�A���?��?a���,>%��?�?T kx?ټ��o�?.OJ?�y�<�dѿ,.���s���V~�
J����>����>��+�?��n�,�j?��K?n�B?������B����=2��DȘ���?;�3��Ӊ>R����>��*�a������sƻ?Z�-?�/��)�o��yڮ�e∿���?�Ac�#�\?�T�):{?��= ��'�e>e�/>	��t��)�?.�V?��>�f�?*Ȏ��fP>�~�o�/>���o�ʿs[�<Ұ�X�>���.ͼ�n��ӸԾq�d���n�1=]����>'�?]�U�����,��A���;A8@��̾��=���?�u��E%�������>�6E?�T�<'>�>c�@
�1?�u���X�?.��>M�۾
�?{A��C��?Kp�>�MP����L��=�N��#�>�?��Ͼ(�(�����$tK?>za?�@A��0G���E�ס?���	�>|�Z?�"?��?uP�?�A@�[?P	?S�S���/�#ϴ��Α�m�e�3&3?�	�� ��>?��=�j�?u��?UL��JƾNѾLY}?0�?.������C�C�yK_��9r?c蝿���>���2�p��^��͊>��e>��p0�Z{<�c'���ν�@<����R��	Pk����?gҪ� �@S?����x�?�d)��.x�Z�
X�?;��>�[��g��z�����������>ͼ"�����BU?}�?ȟ�>��?��ҿ�7�?�?I�/>�r�>b�E?M���p�����>�?��?�!���jo="�?�d?������c��T����?�O?>�P?K�6>$����?�/>���?in&�+�8��m)���a��P���X�>��>�
����)?�]g=�f~?z{��s.Y�d2�>6E8�  ������r'�?�>�~���Z��t��:���?-��鵿X�	@� �v��=����\W�+a���V?�!� p��Ŀ�O@�ς;Q$7?}��>��h<9�>"�>�#�O'�����'�Ϳh�>9��>���?�o��d _>˙��"��?9��=�n��1�?�B?��b�iP<>᪈�w�����
�?�{�� �?�0�>��@Ɠ"@q%�>8	n?]��KRC�l�-��2?�S�,z���� 
������^�?�=@��?��+?	迩�?���>O�>A�!��v���.?��?�s��9���>�F�=��?��������9`8?��J?����3�\���>)��?0]���Oͭ>�z�?s׷��c�?3���=�`(�)�����4>��r�N�y?�{T?
P�?*����O?����P���y����>$���T��=�y@�v{�}���c���(�f�=�U�
�˾�v���%�?�N�?��̿���#?��?yk�t&��f>|Q����=�e��Ԍ����?�I?|j��
D?��K>~�����?e_l?�ʛ<9M\�)<����{�$�nD�����?K�a����>

�$��>&�,��H>=�n?�K��:�>�%�j^��?S��[�?h��>�|?W	�Z�M���T�jI�>Y��?ND�W���3����Q�IǾ?���?j+?��?5��?��>&�>��>�<?m����F?#��?X�=��K��74?8.��c�9��!�7�>)�?�U=?WI>���>�$@#;Z?ҋ�;uq��ר?�QP>X��?�A޿B�J>���>Ġ�W�>�o�9�t>f�O=��9���~ƿ5)�>��d�#=a?i��`)>���/?�� �:P�>�Y������>� #>[�=3�?����;��?�{>{}|?�w?b�%���>Â�>� �<��־q�?�8X>��ٿ#F�?���> �o?���?/- ?��=�e�>�>\ ���y?�<?"��?x�O>_�#?>G5g���>��	?���G>���>9��?��?�^���p?��Ed�<존��4���k� ﾡa�?$�A>E+տ2����q�=�3>y��?�!>*B�>��潖>˿1!ܽ\�u0e�1�X���D�����->�=�h�9?���:��uDb??��?-���E!�=�T��ǭt�	�ؿ>��?�Y�\�?����@��?jy�?�@{������2�ċ�#�Ͼ�����=n?Y��V�o?\�����?TS��H뾛�>+X�>j�~�)徧 ��aC�>=7�?6{��g�y���F@s�k>��1�f^+?세?^=^��4�+�������Ӕ�����;����d�=GFN��ք��׹>��<��a?�!�R��:�T߾I��?��? >	�'�x�����e?�{��N�a?=�2?�� ?y�����=^?��h��簿*؛���}�+���@�*>�T����U�?"�Ǿ��>k=B;༹?�,��҉�>L�?��{�����HL?3bW���>l>���>Χ��s�=Z�=�W6�d������
��?�s�?�C�>;I˿S�&��.�?Ś�?=.�>{r?����ct۾b=ܾ���>1v`?9
P?��?��ſ�N���>��E?l?�D>|H��G�Z��?@�������ܿqУ>ܵ�??񦿣w�����>٢��Ic?��=�u�=(I>�:C?�l���B8��U��������>\'�?��?��`?�����l	�5�?q�ÿ#�?ƫ����/?���$���3S?�\m?���>;0d�6Р>�ƿ�R̾9��=C��=[Ĺ��z�>=P�?#'�>V�?�)O?�X�������^>������տ@j�?ڑA?)&b����� ��=:�J��Է?�K�?w�t?8�b�eN�t�H='�[? =W?c�?��?^��?gR�EM'?f%E>�?;��>���?�<��?p�>���?��>�r����>���=�|%=�Rp?���ߏ��FxW=v�p�dzs>F�ھ~��=X�?��>��?}S����? �����?'9�>�����`��>O����95=b� >\L�3�<?��?eA���ݽ	=�<X��>Ge��G&@�1@�*w?v��>X36�n��?�6e��F\?��t��%���-2���?�uѿd��̸���[U��.�>�2����#@��61�P��?� �	��?h\�=yG?�:	�^��>x�
�}Y�>P1?�e?�6�0M�<�H?w�����?�;�8U���Z?�Ly?%bB�4+!�lſ�l�=r()��A3>���?���>$���.?��ӿO����Z'y���?'�9�_Ӕ����Jx�կ?ʒ	@j,0���?�Yk�UV��RY�?1}�z�=lj��3�=���>�k?����W@��X��}�[�E? �b>�k���?��=�E ?[�0���?Uz@%8��?V=�>A"�?��$��Z�>�龌 �?�N�>����#kK?.���ӿ����А#�Ej����¿w��a}��!��<��>�a��w �8Ѿ����s7���:�	ѽ���?��~?Ȥ;�V1�>�Xھr��Ur?+���0�>l/@(1.�(G?=w|�9=t�go ��=���b�$F?�@@�m
�'�2��Yr�-�H�z#��?�~[�N��ʯ��n>\d�����>g���X�p'>	ƿ��ڽwS���>_�W?��
?X >���?��?��F?]w�O�(?
v�ِ���?�LJ?���?2��?�w��t����??�K�?����3.�Z���~�<MJ�?Y��>un�>��=��8��l�"�u=ݳ�:�G?[�>�V�9���f�Z>�ń���y��>0�>ԯ��¢��Ǖ>N����>Qun>ya���?�>����?ׂn>��b�w�?�q�>~��t�)���?���?����y�ORJ?��/�9"��M��

��i���E���@F�=?��Կ� ? <	?�N�0���K$$��\?��@��??�;ǿ�爾G_?�ֿ�b?�w @S��?��`>��u?�����D�>U�Ͼ�༾�g���n>�	���?�.?s>q���C�?��u#����k?.�?�9�>�#@�h-����?��m���?���?��?�Ѕ��ϿISb��຿Q=0?Ah?o�??ɣy?U��B�������s �/�
�te��$T?��?LJ8?��?��?�b?&����S�/�����S�N>zЯ>��?.6?��>p�>ӽQ�0I`�S���qW�	�����/?N{�?jU8��i3�.u���X5��ha��˿h28>uc�<_,?a.��
?�c�=i�o�9���Z=Xo�?x�T�w��<bf��<��� �}����6`>DP��kO)@gJ��ya@r�B�f�[���q�?�}�?��H��W^�ބ�i�½�]��QH�n,>h��R�V��ϗ><?�IU?ɼž*�>p'-��"?wCͿ%�?"���>�v?a��<@5�?�����!�bg�?V���`?��x��y��v�?W�U�N�8?{��<�K�m3Կ�f�?��8?��S?����W�ܿ�p�[��?�֑����>��?����v0?'n����������ʾ�\�>��R���
@V��E,��>:��?d��<�9��+<�̌�?whE�v�ܿ�ݭ�9d">�(�?{�����z?I��$>�>��h�1�U?a�<����J�-��)�����>�n�>%o>��ܾ�@�
�?����h��V�@����+��?�J)?��ҿ\�οo��_��,俔|��G/?�� @|��>o�a���"?�Ԧ?-���b�>R鈿<Ǧ?0�!?�-�?�����>i,?p�?�?0m�����>r�0?{�����2<`��>�#������?Z0P��C,?/��<��9�sG-?�4�>=�g?e�*���?�ŗ?.��?�ξ>Jt�>�Ж=�"�?�?�~����?T��Ƣ5?y�}=�Cv?�l�,�)�Q�A>����%�Ⱦ�ٺ?G�I�{N�?#Γ?;U�?IkؾEx�L� @�ԿŃ6��ɝ��I��]�3��2���S-�cZ���h�m(Z?S��F��?Y��>+�ȗ?DK�k�>Cc�����?�&a=�q&�Č?$�ƿ^�辋��?�򱿭������q�>��@��?��="?�01?>�N�W�Ⱦb��i�?{*��s,>�?l� @$�X�GYa�m�R��-2?���N�? I{?�q'� 1����>U�>��M>�}�>��%�F�]��M@��
?�2�{>�����o}��p��ֿ��p>�*m?u}"�!� ?���?MT�>"k���mt�	��>*i?�T=p����5��6ݿ����`��߃�?C)���j<\S0�p\A���?����+�ؾvn�?Z	�?�o�>E��?�W��.�>f��=���>���5���6�=������?��>z �?-�n?���\v��$�%����$!?�����T�>[n�>�E?<'#��|?;e��D޿���>�:��8~�����{��ֿ��?2@�m�?~<B�x��?�Ć�
�I����>@�?I�0@��?���]�^�P�?�W@��=�e���"��4�?_�ؿ�C��ߠG�<|ѿ��{�q��?�(�� �?���>�z�>Ӧ�?��>��?ځG�1�\����<�>V��>BF4?�Ta?3�b?@ih��Y?�'��l��>�<�>�پ�l�?�L��s�?mb��#��=�	*>_�&�@da$@3}�R�]?dԿ�o��Y� � ޿���?c�$�Ι'?�ia����?=l���v�dS��r��*?��>�!��X�<uU�Ԯ漜JU>~پ)a�O��>Mk�?�1%?"K�=�X@U�?2el�����n�$?���?1���t�?c;��/L��C����-x?�YX=&W?�� >�.<��i��t��m'�H7���f�>�D�>���h�B�>�����=��|�ܾ݊�X��[�>�Vw>Ύ�?Nf��x�%�?��]?�~b����>�w?�G���~>6��O�@���>9�?���?�+��@bR�A�d?�c>��@�:	�M1���A^?$�<?���>R�?[է���,X ����_:Ͽ'"y?i����'��Y�ia����'@d��4�N�Nq)??��?|*3?���>~	�����f�@	����?�?���o��e�j�>ڄ�?�^	@ZnR���>7s��Ё��˺>hi�յ����(=;�~	@�	���?����)?�k`�^��>��>?&2˿k�o����>���=V�>�p�?�"�?�R?�_�>���?�?�	I�!a�Iz?}��=����:�"��>r�#@��^��Ċ�-�f=�V2�����_ݼ���%=�ѣ>m�?�7�?v�r?��>� �?�p4�*��?"R�>
s������R��in?�X)�,	?�Q�ͺ¾,��X�?Q^��/T�?u�>G��P?܈����>/]����e��>�2'��MJ��^����>�ڿ��࿄�>4t���.����W��?���?�;Q?~��zː�x֜��п�P�?����K�_�/�L#�>�XJ���� ���z�?⍾�qh>�;����>�nM?�q�?��b����)�=��u��~�>lh[��p?:\�~�z>�z?����@?Mt�����1?���?�������?4�N�@�J�������F?�?�Z{?]|\�~e���ƿ(!��+�>u�@!U�:t@h@10?��Ŀ0I'?��>(��<ͬ�=C	_>2��?Y�T�I�=L@��q��?'E��χ?��]�?&��>]��?�����2��|�4�?��?���?���N=�?�Y}�`'俓�п�`H?+]=�����y?�ZI?/.�>�:���?��>`������)\��²?r�+�I��|y�7,?��̿敁>zf�^qP�'��?e�>�f�?�?X8@t6$�I����?&�??A?�D'��*���?�MU@���l[�B/@�$�e�e�`/?Y)�>�Ά�
t�>�(@'>��@?O5�>)T���/>ɱ��nH�����,����5���&?�p:>lK�?��?�uɿ��?�n>�q�>
�>��`>9�2�'?=��5�q�����?�=��FпO"�����>��
>:���dӄ�t�=��x�?��!@N���J,j�u0��&�N��D��N�?ˣ-����?���>�y�?�I���̾Fl ?��?żs?crQ��H�=�T?15=��?�cԽzѿq�?CUH>fG�?������=��?��(?��u�	�D��}Pb�2�b?�}�������>�-�?�f0?���$��/�?ʗ�>2G��V���f�+s�?�ͱ��LK��b�>#�>�\?��2>��ƾ|
�du]@�t�?��
@0V���>��?���B��r�(@*��?���>:�E�Ch�(��>P1�r1�?�K#�s�c>����+�>h����:_=�Q�>��?X(�?�9�>L	H?
Vӿ�%���������<콳q�=��d?G6�>�p�>:b��]�>�]��;C���>8��?�~��~��˨��-�>b쐾��Ҿ����B�?�l�>,�O�L��?�Ӿ��M?4!½���>�房��>��޿0���1�X���4��}��?����S>v�">���<P�>_�+����>P�?�<��%?�r�>��;>?x�?��ֽ�`��Ho?H0v?�F@���?S�ǿ1�?,5п����B=���翲+�?�i�?O�澡����u>=��>:e�?R=o>;�޾U�?���>��+=*��?��G�E����տǯ?�y��hǰ�N�\?R�@��޻�W��"�-?,��?�V�-��K*L=��?,7�>^�'�#��?�V�=�uQ>x̹?���?Aj�>�V��B�5s��{�?���j�I�>57����sM����(?��:�3�1y*=װ������֚�f����A�>���>��=zU�?�Ƚ����]�z�?<_�?/�?��>ъ�?@�o?m��?�bɽ��>ҟ�=�̩>���A+�>&+��=��=�@���$���ޱ�?`��>�EL�..�=Yй�"ܘ���@�*o���
���?�B�=��e�b"�x��>&����H��Z'�l�<?�����?��>�Y[? �u�M?J����M@�� ?��?d�>/WK?�w�jTZ=E�?�&#�K1�?mϽ�N?�?��-�<�=��y�ԾE_�䭪�������L�a���!ÿ�/@�]ۿ�l���Qk?k��V�0?c��F@{�P��?����Sk��/��_?���>����̵>f�=��	?(�o��#�U�l?F,�>q��?�v�?����+{��o��8@�� �?�{5��E@�9o�de@�o?��@>I��P� �h��>B��ת?�=�TS���ƾ�묾1����K�>o_�T/?!#���T��~��>��>�s�cp,<���;��m��?��g>�4�>ml?Mn��q�x�Puj>�$��`?N"���?�?���?`����5?�ſ?�0/?��@>�t@��u�>EU�\g)��m�>p�5��ֿP�o���%�I8&�j���Z�{p	�~�?��ܾ�?�D��<��=}�Z=I?���sCv�J�¿O޾�b^>�HټK�����>�>�?U������w@����5�T����g�=�������?L�X���g?tN_?�]��O*�?�� ?$5ۿ/�6?Sǻ=���>������?��ﾏ�_�hS!�(2@�b�?wG�>uw��S��?Ы%�N��>��>��� �e�ȩ�>a ���^�G-�?E"�>�V>K�?L�����C�B�-�y�6@�J9���?����:@�K���>%E�>i�ܾ�ƃ=���>Gn(�Ji>��&y�����`�Z�#��h�?Gu���sl��uj�`b&?����op?��@��='�
?��?)Z�?�����I�?�{��M��U�?�rT���?v� ??M�=�ƪ�H�ǿ��J�
��?��@<?(��m�y��<�Y'���㔾���>n���>H?2,�=t�?����6��� ξ7�@?��;=��ǿ��+����xQ?1e?��5?��a��*?�@�?�P��rhA��>�7*6���.��M�7i#���ӿ<G�6��?��?*��N�?4�r>Ȭ
?���r��=�[�?�l`?�$پ�=���CU?
�@�q ���+�e:����>:��I�?P<?}U�X�9���?M�?liQ>�W��)�9�����/���|��LN���?�Ǚ����?Q�>���=T(���C?]�Ҿ#T�<��?��>���>�a����V?.^��µ� n�>3%�����?)�^?Dz��䮽�K����C���H?�bS�ڼ�>���=ޱ��©?[ �F�I�u�C��cm�?�(�>2��Pa���R�>3���_��=��D� �>K�=Q�5�A.M?�s�?MT2�BoV?��G?ݼ�'cK=����j��T?Qp�>�R��O�jV�=��ǿ�И?u��?O��.U��J?��p�"ɇ?�;#=�W>��2��Gs?)T��X��Lž�f�>��ٿ��t��?H��=׊f����&[�1mL��>�?��w>��=����C��>h�j�x�f�b ?ٕ?g��� ���@�?މ�?�C?>\�?7��(       ��>3�����=�k6���齪d@���8�������=׬�v�=>�
>�}!�ګ�n^4> @�����J���P�h!p��:����s�<d�<¹���< '#>3q>�l�=�����=8E���$�����a>Pܕ��\н�?���cT>�F �       ���=�}��V.�<��佒�
������=�E2�o_�;�f�=`�<�[�?)I�wQ<��=c�ϼ�M�=W�ټɡ(=�ɟ�P       XMM=�C�=���֌=��۽�E��Ϫ>))?=��>
�>ݨ��k��{{��=��>�t�>�B=?}9D=�O����>��>��>�s�>:��>CK���Q>�9=�Ň>�s>6�Q>�_�>���>����F��g�<�Sg��D>�0^=D�g�Gۼ�)Y>|MQ��(�����^F>�]F<+'��Ǯ�>��_\�nX�=�O��P�=��������$i5�2�@�2C�<A}����=�h�1=�:˛�=���=�9 ?�M/>TP	�\�n=e�=�	�;�u�>�}�><�>���>��>X�:>B�_>�U�>��>]��>D�F>@      F�Z��U��W�w�>���=fZ{>��½�Ԟ>$V�>{��􆰽�
���Ͼ?�2=�;@;��9?�'�u��N��?���>z�!��?Ȼ?�s�>�žTj��$���Ӿ�K?�#��?E�V?I�[>��3���՞�=�P���qk?~?>
b%��@>�9>�N.���+?�y-<xG����<P{�>#�W>w]�=! �<�>u�?dF=K> ������=��>L�D>�h2���E�$Q�E$	?�3>�$>N髾r˛�[�򾗱�?fu`�|>�?c�x>��`?8a&���v�7h3>�R�>eV?e����:?�}=����a$|>j�	���ٽYXb?x�:>*n�	F���?��#>��Z��V*���?P��>}z�<#!Y�>-�ľ�a?������?,��Ϡ?�n>���4 �=z$#?Ăa=�cپY\>ߗ��w|�>���`��=�f�,�(�>jձ?G�ֽ���=ܟ?��@?��w>�t�	�N��k?e-�>�x��GՎ��}����=7�����w����|�E�>��>�K$=p/�>�����V>2cݾ�O�>
!�>Ļ0���;�f.>��>��<R&�gƏ<\���3%>�K�>`��=*J�=k�>��ܾ�B�BQ�����>!�i���I>�#�>H^)�P��>$��<��>A��)3�>J�c~,=�~�>��	?-��>�I��^*>�,T�Q�-��F�>�A�;�z?c��&=�b]��_p�>��J>��a�Ơ1����]��� ��4g��L���ܿ��U��#�?�-���>'�����q�ؚF?�Ɲ���?���=���=��C>tg���输�+�{�8?@j�>�8��<ʽ�5��n�Vx?��[�L ?�,?K[�=�>,�?�{�==؉><�=��>'�#�a�>��;>���>/��<�e��� >���>��}��>�*Ծؔv>��R��G�;��پ�m?	��=�|��@Z?t?r?����.>@�=�7O?����3��>��7?���>��X>��ig>���=�`�>����lbR���>����~f;��"+?q���g�H��_i�4�G>�;��Z����>���>�>=��>P��>�7ν���[?I}���?�"&��>4຾-�̾�����徘�Q?�z>�pE?�k8�!P	���&?h�%�R=�C?���>�e�޼��R�$=SS�>�b�>@+�y@�=�k���?�55>}�h>k�'��j?E�>#)���I��ÿ>�����=�=h�>����
?+�>j�>���>m��^t������`�>+�����{?k�~=V~e?�N��T��M?7�;Z�>�^w���Ž˖׾3E�<8�=D�=��۾����o��g����/���e>yq�<�����2�x��>����оu~�q>��1�DH�>�41����j�>�{�Z`?�'��. ��>I�?^����=����uA�>�0N�����O�����5zD�A������>���?6�"?X��6�?_���ᾶe>�T�?���u�j�~�^�u�C?�	�$옾y��>����כ>y�>�=�OM�r%G���>�=�>ns?���>_����%>b�S�*���>?<T*?�S��څ���g�>Y(����?��͂?�=a�M>B�	>�5���iq�uؾ�/o>IӀ�L���ɜ �w�=%�>%�>���x�!��3k>���>Qdk�]:?�o˼� �>S�?��c5[�?w4>SUN=�i?I�m���a��E?�L�O�=�:+>׿�="W��"� ?I�����]�2��~��>rX>�@K��
?a�>{^�>��Y��e2?�]>�^��ͦ��#>�,��n >�9���>¬>��Q�ͪ;?�[�>�k�>ў�b;����������\��⿥>E1>�y��I����\+>�l=�9�m�*�<B�=��\?�[��{ܾ��/>��.>�Ԫ>|7?�s��`���|v����>2��>�>�t�r=��>AL���H��6�E>eϤ��һ>�B?Y�?��?|��>
ʾ�̨>��?����j�<�þ%\y>��*>�>��;�o�&����^>���k�ܾ�l>T�Le��0�<?��}>q�>�ž��E�8XM=�q�=���)��=��(=|�>MB4��ˬ>�����>HS�L�=�p?T�5���>
�>NQ3=��->5�I>X&/>��!=�$���Xp����I q>U�1����x���?)|�>X�>�E��}��f@>���<]*U>��i>�N?�#�>�4�+�Z��>Bb?T�[?�E�>J܋?�kb��S�>p=c�h����أ���>/7?�"?�7">��þ븛����>�?��V��Z�{�e�{�{6N>&�b?�C����о��>r6>Z��)�g=I����2>	��>»�>EwQ�3��>�K.�V��!Ƌ>��;��>�ҾY&���:=Yb��F�>9�>8�6=|�F>�(�>�ݚ>�l>�f�@wf�$�߽&�>N�!>�	!��~��
�=;�6���ѽ}a>D܌���۾�Hk>�wG>�i�=�߹I����G��$���>�Q���<�;T�e��>� �>=������G�>N¾���U��>�ѱ>�����7�>�'̾�]=��:��y�T��\��� =[�O>mO���?�)��u%??���Ͼ��[>W/?��5?��[��
�>�����*>�:���?I5�=�����[u>��L>�>�>�>���>��6��=���>C�>L�a=����y�"���������W���pF1>�@�og=VQe�9�r�]��>��/���Z��Ԑ�����>�z��>n���n>��T�cH���<@�.>�ۡ>Ȧ��Dk	<̝5=�Ď?QM%�����;�|ğ��H?�RH��r�=�:�>��>�(�>�Fq>��R���=�پ��4�����8��\T5��=�P=&��>�_c=�n���W����>��E�go�>�m�>;X?Ƣ�<H�]?���?N�?Lj>�r� J�>�́>�����:�t?�V�L p=�;�>�轥X�x�>r ��3�>a��>�N�>:��<� ?���f�=b�M�f�>�r����>V1�*@x�(����h�>�J��nUƾ&�B>-�|�}>\p?�-��a/?0�X?�-?H� ?)o:?�6پqը=�9̾�.?"��}ƾ�+�>��>�%H>1!~>X�=���F��<q��=d�w!�P0�|�;[�X�QnI?�J�ޑ�r#.�F��>1���R����>��u�	赾�W?ɤ��'�?����X�Ͻ��I?��)��q�<\�I<}��'>�>=����>�AV�@=�<�D��x����>�e����G> ��=�>:����d
��d�������%�>F��>u!?83����C>�<�<Ncx=�>�U5>w�C��O>`*�>�_ξt�>��A�M�[��%�>���>.ٚ>Y!����H>���>jY�=�<�>67*��B=�/z��+?-q���y��w�pU!��i��5禾X=��!�iht�X��>���H?ó���=?���bA��N1���S�>/����S���>9B	=pv=�hھ٩>=ݽ�|��U+P��~��/ϼ�!��"��>��?,Ⱦ�t��C3=4⳾��2>Ȥ��#�@�iTȽ�|T���D�==�q��?�^?���>��$��Ⱦ	��=H{>=X<���>��>�t�>��K>ȷW�T�>KU�ʱ�� ��>�0����=6l:�.����>;���A���>_/
�@��>^,T��n����ނɽ���ӖB> �Ⱦ�1>>��>��>�/�<M��K;��C����?�r���8W>�,>��?6½F?X>>2?��>��=���=����m?�@�8��~9�$��m�?���F���1z>�e*��1��m�s>3����ݾ���<�鿾UVD��_ھ�ҽ��c?2���7�=48�>�!���==? z*>\��>�U��Ӈ	>��>���>k�+���B>�H���1m�Xk9����=�"�=jI�������$��v�=ZQ���	��ŽA��ĉ�&Q�>5>��=�_�>`½���=�e����J=�;��>�>q�>�#辏�=�����>�Vc�6lǽ��>*@�\?��sx�>���=,5���E#=�Ƽ>t�0>V�����,�;=�=�G��ba��R=��>�-x�u88?u��>N������=�ξ�W>��Z��e?>�F��|ż�)>�ž>�T���1��[M>�ۿ>gR4� >�/�����>P����?=''��۽8��>�������Q�>�A?�d?�k���>߽?;�`����=��$>Z�h��rz=��=!5=�B�յپ��ո�=}���SLB��6N?���&Š>Ô��"���=�-
?�E=��*?�^�=�M�06?8b�S�=#�>R*�=�T�>��@�K��>��оy½:��8>�6#����=�#?k�D�:D�`N�>�j��g޾��1���r>sa�>�2�����w)o>��½��%>m+Q���)>��(�|>?��>��3?V#�><��>�P�<�ڜ>��?� n>��	>52(?�ɾ�?T|���;��>[�N����=�4>Ǖ!>}��|(�K��>�>���L7޾�a�����m6>&�"��&����6?0�?>��o<�?�6��I�=�L����d��ΰ;>+����=+)���=��=%�=��'?DH>�`��� 9>MӾ1�>ɜ?�@=P�*>HU�>G!�>�=���V0?@��V\^���>�R?~-}�&�n�!;���n3��?X�����Y��>�v�?@�����G?��>�5��\:?�����>L�ӾqH�>��v������>[W�>)�=4�>W�=
]��|��=�<+W˾�!��=�S>[�e����=#W�y�<���>��e���
>���<�`
>���y��>T���w����>Q�����v�ߓ�� V�;b�?���>]%����	?��>�>E��>O(�=�mZ��'�?�=�i�>��>���Q�t?���<��5�vk2�u�=Ў=��=��d���>
�I?�gս����kb�>�cR�$~?*>V�>bƈ�s�m?�h?�j��\��23��W?ҭa>�S���0Q>p�d?��>�3>_��=�L?��r��>��4�}2��GK?��=�?���� ������b>��Z>�7�Y�>��=z��>�sv>� �쭾�_[��=��y>���>�NW>�Zྜ�<��?R>�J
>ڮ�>��<>;��>��Ľ�H�=��X����>���>i���AB?��j?:��>���<�%>%@M�@�<6�Lь==z¾1�@>��!?د:>Uh��V�yu�u
?=>^h=�� �42�=fW?c��>��4>B�Ǿ3���N��&j>l�{����>{�>B2h>
�~>�=,T>�V�>�eþ�a�ߘ����=b��>nq��ڬ?knj���t�\.4>v�,?M1�>\�b��E����`Iz�PU>Q�>U��>X�J�@+�>*���{<�=ن�=v4��w��>�T�����>����=]�ۺ/�"��'�>���>a��>
�������<�	��i��E�6`E?�w��%?~��>w���2��<A$n��w?���>�f?�ɜ>�->�,�>qw;�V�=�3?�'D>�g�>��=p��=��C�^��τ�n���3�>R"j?#�>��>�Q�!g��1 �<]�پzz�=�z��' %>.�=X�<H:�=v`��>�d>�.R� ���\�"���?>�F\>�,�>j,Y�� >6%��v�>���=W���TX�֐>�����>�������>l\�<�X��R5?@O��gx����>�y�m�=�E�>x'?ZY������ώ�>�����$ >��(�ҿ׽�J��j�V><3(��`�=�c�,��<�=��۱����=��?���>rޔ���>��>�5R?M�ŽVM5=�<Ⱦi�>����u�;�nB���>KѬ>�NN?���?B6��\={Np?�l{�9��?y	�=��8>M,��l��>@�??vJ>�ϼ����)�H7�,�>}p�\_�=(���j�=?������@��↼ۿ��g>�H?rI��ϼ�=9�$��%2>7�>=jgǼ C�>��<�~�>ye��f#�3&��� ���ƾ@���QD=�T;��)8>��.�?�bA��N>*���<j���Sܾ� ��?\�>��"?O�.q��������>vh>����{;F=0�1b,����>P       y�Ƚ�Y>�,��1=�	!=dś=�� >\=)>f��>'��=�'�>Y����o=�<����o�>P�t>^&�>N�? }2>%B�>z�9>���> c����>A���=5b�>DH�=	��>�7?��"�o� �)�I�˰n<�+�=h�B=0u��⦽7��>���qҁ>��h�"�>,��OCX<틸>��f=�B;�����ý4�=�1�=�<�;�]>y�$����>�t�� ��XgS>8l�>_* >���>c�>-�>��rs�>��>������h<�/u>tx�=u�@>�տ=;�>@�l�tF>�U;��>�M[>       �	����G� 
      71�h:a���,�����K�=y��=�v�>��۽u�b>L�>sA>�p��=��C>�D�=�C>{���k��<fi���ޅ>�D�=��H>�I�>JG>�ob>�u>����}:���I�nb��Վ���>up��O=(�����?=D��v��>*q)��Ɵ>��=���>ޡ��r5��u���s�>����$-\���c��9>8W2�~`�>HX�&6$���j?nu����t>��(�lV?.�y�r	�>�,�>�	>���=̶�>%�>�EU>��$�)����=z�0>3w�>�r�����<)tn��P����>�%ƾO�G�����F�6>��>�2=y9I��h��ҶW>Hd�=w��Q'�C}?�-��4������5c>��p>d�C�nS�=$$�>N��<�=��=�o�=_X>Pp�>��彐��>��E?;�=����	B>nj;?B�n>�߼�|�>�񼮚�>	R���Wr>'����>�� ��J? 㾆�>����Waʽ�G��B�>W&��_�L[��ӟ�����rZ��;�N>:	"�Y��!f�t3��|>�w>Ƚm��h���7>��$>���;�z���7���?D��?5�-�����7T�=K���J��#���[>4>�>^O ?0!=ƕ��Z�>5��>%��@�ɾ�2����]5��f�=R��>Y>\�4>�.�=�`��،> �����>a���!2�2�=l�=�f�>��>�,�>�F�>��E=�5��w>g5�>Jh��b� >�;:=D-I�W��<߲X�N料�_S=_@>��Ͷ�վ���&��=&�?>J{u>D��MϾ�����%���r>^	�<)�=/����>���l'��k���>),M=�~>���꽻�$����;���>*-��HG?�xK{>&����7=�=�>i-|>�W¾���82��">��T� ��tJ>\���Y�m� ����i��!���=��@>�}�>R��>L�>���<Wg�>�ؽ;F|>Ƭ	�FC��������=k#�V6�+b�=��b��l��^>�]>6��0 ��G|��;�����O>�`#��N�>�
�>�T�����>0> �ܾ���.<�>�/�=[#-� /$���d=!9>�����>.�->���=�iG��}��}�=��p>K�0>F��<�ab=�F�������>0�ｬ�>�+�='�=�؎��#>gq�>y)>�K�>���>���S+�;���=��}���=�p��^�>뺪>G��=��J�Pβ>���=4��9'�>�B����T���<��aT>�>B�>]]^�nK�=�G�>@5> ��=O\d��T��)A�����>�ֈ�t">�C��\+>�l录�@�!t�>|�T������dc����=]��="����!�=���>�k�>uþ�=>��g��zX>�O��T��>���x���Ŗ=�x۔>)?y�ĺ���ݼ�	m>R���l�Y���k>h�t>[*S��ށ���<.~��{l���;<j�<=��������)?Ɔ�>�u=�{_>̭2���O?�r���>��>�����$�ٝ��$��Eн(ؾΛ>�)����4�5>v�нm{�=�bX=�C>�<p�����>"s(>;Y2��J�檰����=>����"�[q�>��y=|�-�׍>�Z��E澞\?�u��~�a>�Լh�y�r[->�n���>��<(�_=�� �i;�>���>_��>)�z>�1�߰�>B1>�Wo=���+o>�6<��.��X�>ڕ:�{�(>\n=��$>7�U=4�
�gEe��Fe���T�H>6a�����>�>D�?D�>�	�������>�П=vP���%�=�w}>�?�m>a��>�1?iZe>�
��h�� m�:���[F=^����7?�U4>�΃>�!�hew=��w>��^�k�j>]��]>=y��ٍ_>�u�> �f������N�0x�>�;]�I�>go�>���� {>��>�@��8_>�ʷ=S*�=�Z־�񛽁"�<�f8>���_�>��;=lX>1���]�e���p��=o;!>��x=^F��k�>�	>�(�=��>5��;������i|���>x��>���>C�������͊>�{��yB�k�D��Xs<���=�!�>9��>e�+>�����>�k>�4���>�j�������}>CHj>l�J��:=��P>(�L>	�{��*��6�,J�=���=vȬ>��>?�� h�>Dm�>�5>�0y�(�;�n龟9<��&��>��>VA������>�h�>��S>X����橾Ҫ��+�>����ba�<: v�'�>g�>���;RBƾݷ~�i�	?%�+���>jw
��8>�R�<8=�{+�"r�>O_=�g�>T̉=<�о�����`>��|>��>J�>q���_a=F���/���=ǐ���U��Y	?˾n}�����C>y��Ʉv>-�ҽebQ;B)_>��0>��`>,7=�yt=���>���:���=�%=u��<ܾ>KC;>�9�?>�B���{���������蛾�L�>:9;>�)�=���=+>�>1)�>*�>k2X��ɠ>��V����>+���������&
�V�?���������<Ͳ?m�_��盾��0���W�w�?>�[��*�>����������=�Ğ>z�� �>�A�#c5>���=u*��S$�6�?aVM>{dQ>y�� ?8�Z��l�>x�!��	ҽF̽���>�!t����� �?��Ҿj�9�����T_>�W?>�>��>t�+>��>������=�*���-�>���ݩ*���B��׌��'�?�t���Y��I�>r��>^�{<,ڒ���Ծ���]�=��>�ݕ����>T>��wн%~;0���!>�`��T6�>"Y3����) ?4,>	:=���> ���آؽ�и>�����7��>������Ǖ<���=����������U����Z�����=`7��Mx��S�=���ν6��<�3u�SCѾ�4�> �Q�y t<C����%rW���F��>o��&�B?�%���>�L����=���ŝ�ͩ�>)-
=�=4��>"�F�� ��%!?Z{���� ��k̽�n�<
��m*��H[���C�=�ӈ�����S>�������qƾ���5�r�t�?��=�x�\���R�<�4�=��C��O��Iɉ>]|���׽��	�`�A>�C��&d?��D��a�>鼛�9�>	�޽�q��p�����(/�>�;�<�;�=)����
>1ܒ=�|� .�>{�?��h>�^�>�`>��=�x?�����)ټd�?A���i���(T�/>\�]�u�?`��������
?���?��.��>��T�|�Ѿ$e?�a��ڞ׾���=<w;��"> A�>�� ������˜��@>Ҩ->
�4>o,����=��?7�#?���;��XL�>��u?X|�ؗ?&m��5�o��	��L������V=u��=<�ؾ���>��m�)`!>0FA>␜=�q��2O&����>��F>R3=�j�L>|놽Lm��/i��y?r��@Ͼ2=>�2�
�
��@�[�Z���<���>���>>��>s;?��>_b�>ɛL�Z����ʾ	}�=꯳>������<=tRr=Z�>��QL�>�.}���> 3 �-u5�>أ�����)��~P<��>:�>��>��y>�r/�Bg{�����z�U�B8m��ȏ�
�>���� �>�!�>�W#�A�/>���>��s>�@ �3ƽ��.���>:ξ�|4�/���S+?�P�>�5�=.�Y�qrþD��E���8�;@a>��f��Y=J�e�{a?���;5>�/=�jA�>DjϽ2K�=�Q=������a����&j��qϽr�<SA��6>C=#' ���˾���=Q�=��>^ ��Ѿo?$XȾ��>ր�x�&?�\���}���=0^�F�r��z�>��*�����[>������>s63?�?�>8��;n�>|?���䷜��~>�Ͼ�Sо�e���8$���<�T?j�Ⱦs? Ծ�75���þ����G���i4?��5>E�:>8�>�P=��>�i�>����xz����b��T@�>�l?P=����a�>�I�=�Y�>S';��f�>E��='�(>��>뉣>g�ྛ ��^u>z� =XY>+�O>�l�>g����qa��憽�ɾ���}��<��'=}�����ή�.�W�����-��x���|:����_�Gv?>��>Oo4;��=KXw>��>fD^�q1�=�՜>�l	�UYf�ڡ�=D:>����}�Z=hy��
G�vf��kv=�G�>쎾	,��ڗl>�#�I��>\�d�'�R>&�6��N��3��gE>�v���ᆾ�d�>�y>�z����F<\���%>�%�<���>e�$=�)�>K�/>��j�t���2�&��:�u�i�ֵ6���>t��=b���B�>X=sP>{���kD�G��=f�W>�IG��xR�V7g>Af���>fD��>G�tB?����S�>߽a>�A= ���O>�B�>|�E?,R">}�����>N���s�=��=���>&a,�J�>����R����	:>�!�d%h?�QT��R}��>Hމ>��Ⱦ�&��4>r��>Cp�>O����X�m���e�>l�?�vR��=��H=/��=��<�d��{޾���>#!�>��>����&�>|�*?@>(����-���l���r:���>H,o9��>ފR���?�歾�`?�R�>�O�� ��ns�>
��='1>����dޠ��-S����<�Y����d>�ƶ�}@������q��]ý�>��!��8>�i>ܪ>�!?J�}Y�=L�?��?��>�S�>���>m>��$?V(?F+,��"��)z���?� �E.���D{=Ǽӽ|rz>�3��M��>�LĽ �<��Z����¾�?���|3�<�L�[鋽��>�a> ��>�?(��>���=�B�<aK�v�[>T=�*f�|sV>��k����>�ʟ�U!�>�Ӿ��Q>��>�nA>29>ʬ��9�>�*�>h���H��>	71�`�m>4C����Q�i�`=���=���=�|>���>ZG=�s�����t�q�?��>
�ɾ�)$=�8>�p!��1�=��>*�=ɾu�>T�>���=V�=|EI>�9��X?rS>Y�?jwC�"��`R���?Rs��	>����($���ھ��$��_�>{��=��,>����ĽF:��2:B�2$�=`���ɀ�<������_4g>��>���<�=7�>�>*j����ɽڗ���A>�?���u�A=LV>�̐����>�sZ�0c��F=ASd=|.=�/"?��}=�>$~�~�>V�>��/�:R>5�5>h�>��t>r������
@��mJy>t�4>=�>ޕ�g<�>QѰ<|J�=:G��|,���RE>\���Իh��[8���<:���6�6��$>�<����ռ�ѱ=�>����u9>FȀ��a=�>�į:R��Jjr>���<�.[>�V��h�<�]�Vf
>!��=+�h��=�X�>UJA=c'�=�P���c���P	�{M�r�����=#؀>���=���=,�>�H~=���>�^�,u�>�)�>�:)=A�<��?L�v>��>3��A�0��ؖ=�>��x0>47j��[�>�ɽK�H�eK�;�n�=�;<bp��d�1�u��=ūI�՟�=H/>��>?A?�Sɽ.�a>����􏾁\�>6X_�s�>��w=.{�w�>O�O>��k>o�b��e羨<�>�/Ҿ� ��U��7)��8�+�������~>5U㾡�
��+>�T��uk=�谽�[�>k��=��������������y>�E=�|W>�����ذ>�P\>=`{�	(!��o��W��<���=ht=��>��ٽ���>^��K�g>�j_>sr����=��ҽ�_�%h�<?j�>��������u����뾺��=4�'>�2�>G��g>��;&է�PJ>��ʽk~>4 W� ��=�A�<�FR��W�a#�><���޻�pG�=n�%>o|���;>��->­3<�	־�ۘ=�����1����w⼛���!pýbָ>L��=�f�>b�?�>â�<bΪ���μ�w��w�=�=z��yh>��=˫>�瀽=�l�=�ev�=��ڽ��Z/�`>0�G>۵¾�䰾�Ԩ>� ?�����O=��v=U1>0�^=�.ھ��=<Eʍ�/�Ҽ4@�>cY�#X>�ľ�QѾ[NI�Cp=N��=����e�N�k�7D���q�>��؋��WO���K�[3��_vp>���n�>Z�۽�B1=K���G�0>?'�2���ͽ�N�<>�_�g C�w�@>���=�yU>���>NC�<=��>=0�<��z=f�=�e�	),��>\>�)���\�=�,�j'��iL(?��\���μ�%=n��=i�*��@=́Ͼ�#=��j�>#d�;PV;?�����'�>��>b��>P\߽֐U�Z;���������^�1>�x�>I0��`P>�(E��)j=`����J���������w|&>� ��YL��T�>��P	��c��VG��W�ھ��յ>L��д=RC6��?�\>�j���P�>�Av�.���d�>�u8�c�������%��>�7�v>E��= ���9����<K�>��o>n��T��=ñj>�O�=�&�l�?F�Jf>��>��ܾ�>`���R�"�P��d�(>����D>?"?5{>�({���>x9-�c�>��%�S>d�_>`���E��s2��{�>�J��d����>�A>ؔ6=�ō�c��u@�>�u��Q���Tʨ=L:�w�?��&M��4����_k��>�=�׾�>Et��;R;�k���ʽ$/;�	7?GA�>�^>c0о�Nw��N>Jx>��>��D�H��@.=	_E>���������->���{�ƾ�Ǔ�~�D>'�ʽ?�p�ە�>I�o>II�{-�>�N�>@ĸ����>/O�=�,����z��6�>�*�����<KF�>�}���+޾�6�����q��h�>F��>8<�=���=XR4�eȳ=y6���E��u*�=��ʽ�ھ���>���=_��>�޽6Z�="�-�ؽ�����=�>�M��\���׽�9��<��M>���=u�>�0����;�7��=�"\>�x�=�
=W9ľ�P���,����S��p��4s��S�����8=�|�=J]�>��QM�;�
*����4� ���o�Í<i��y��>J00�i�=&�A=*�>���<"f�<a�����>���=+N>������#�Y=���&��='u<���X���PSv=Nc��e���s>���Y�!�¸k>%k��nx>���X�=� ���+@���=�R�>���>��>	<��ɡ�����>����q�)����b!>���>!�=���40��mw<�x�R��>O�>d5D>Ah�>L�<�w>~5<��o�^Q�>܉�8R>e��H<d>f���L���s����F��BV5���$�|��>z�>���>��>�]���P�n���3)��v<?H�>ξý�5���ɲ�X_ɽϊ@����=����d)>�\~>���>ǎZ>%'���'>��̽H	���ڢ=��R���=��0��};<������%� �o��
�=��<���k�þv�=7X�=�#��./�X��f����5�I~ =�C�=`,"=A�>al�=���}>�[����^�G>_v�=.�>HG�>�������L�=ϛ�>0*q>�j\�Є���p�>��>obT�Wݾ��|�E�>�R�<9>���MA��$?f�?M����>� <��i!�{L��c�>P���˫���`���0�x����=R����漍�.��>���R?�'�<J�>K�@��=�>��=D]����6l:>�O��DV��8�> Ź=¾q>�ƞ�6�L����m�>�|���k���� >��>�J}��M>��&��?T��-�s�ϭ <oG�=�< �
�?� >�>�D��Ȉݾ+O}�)=����>�P-�q�+=$�x�H�@YB=$�>D�����E��3������IS�"��8<$>[늾a�a>jvP>n|�<�<��*#�=|� ���>�6�;�m>�6{>��R>.��u2)�~`��u�>Xn�<��-�,e>T�>e>|�- �W�Y���=>o�*<���Ť���o�mv۾j��=����]�!=ஔ> l�Oə�$�>��E=��=�f�=��7��nM�j4�>�BK>q	]>Q�>#-�>s��n��Nj����t>�{>36p>�ՠ��W�y���/jR=��>q���������>��!?�G>�[f��C��x�~�/;�>�h���=��3X���q��q�lAӼ��X�٘���AV=	�:��S,>��=��6�z��N�ܼF=>�w=`� �`2�=f�?h�}=�������Ov���z���Y�����ĝK�F�n=n��<�=�l���׫�g>����,��>�&��z�T��<I�=��?��@>=�,�/NԾ�t��5.=>M�=�֒=��w������a��>�o�e�=��?6���ͺ>���=@H�=:�9�M�=)Q��;Ҿ�q9>��?�`/��OJ�������>���������?�<�)�>Y2�t��q�=RA>��`�:����$�=ܳ>Ӹ ?'���g�����>k��n�ܾ���>�B��x'9<9�=��>7M>V�<[zA?heս�Q��ԣ��:ž��5B�������!�_����^1?�Z���~]��yy�*hS��1��H�<d�)>��t=�>���+�c:�ag�����s�ǾR`�M���.8>ױ�<V�`��*�j��M�>��Ѿ�(>�B+>fi�=i��=���>\ X=�����=��==
���>s�x���߾���'�>��>�A�>���������S��o��(���W�E��>�e(����ɋ��3CC=��ۥ3���ݽ{K�=�i�����7�i=��_<�a7��7\=,�?V�d>6��=���I~ܾ���>Ln����'����=��T>�J�=<��9}�k�>|->K�<>�3w�Z�Ͼ��>��?·->Jj$;ש(�W��>H#�=#��>�c��ʹ��U�I�>�8�>ӧ�oD�>�8޾��>�~Ծ�U=�^ ��=�(�=��>൐=ȫN��K�=�zܽ�,罢K��>�[G>g�>��ýT��>�fG�  �<?ò>BZ���>"�>�xʻ�	�=�Y�`N��/�D>���>�	�=L|���>P�a>~S�>d,	��-�=�3��w�F=���>�������7�Ǿ_n?��v=�f���R��2�ξ��˾�f
�X`�;��=>tuԻ����٧>�;?o�վ�0�p;�&��>� y� ���@>8E��z�c=��O�������\���>f�>w��](a=�i?p?����>��?VH�>��佊̴��}����>�� ������l�k|>�&�%r�>4�>|��>)�־t�ԽIΌ���`>�'8��,o�&؎<�q�>�&��f
���f>�eW���ƽ�e.>c�>�m,>W�?^�d>���>=�=�����f?�/>�X=^f�=W�=[,_>&���ZG	?~��=E7Ӿ�X8�+1쾣߆=
0�>��	=���|>O�9�z>>�G��A> ;��CD�@8?���<H��������?�{,%?C�>?]4<��>9�>(f(�*$r>��F=���{�/���> ���?�=y�>��`=ei�>W�>1$���M>ռ��-b�>�	�>B䜽��ھ�N�=N1I�|@?s�>�Y����-�6|�=�W=�?�>�Iɽ�#b>e��>wd�>~E)��A>-�>q*�>zS
��7���7m>�<?��I>#��=�q��� �o>�s�>����K<=��e>H"��f�P��d�>K7���Z>|z��&�>��S�U>�d=j�	>�>A���>��>W9��R�2?���>Xʗ<������==��:���i�       0����*>8��<^��>W���e{��S�=ُ}��T�]���!�>���>	�=�� �K�q�H�g=����RѾi���v���[=�J��E�=x�</��=&���p�1�=���>z�1=��Z�M��
qF>�`>Q;?����= ^����*�唕�>�Ҍ��Ş=H�����Ґ1����`[�=m,����qk;�_��>G^�=�G'�����2���+=�_�[�>��3�=���!|6�'>=|	�=�GO>���=��q�O�N>���=�bܽ�S[�r�NP�=�笽^>��A�:����=�=�SY��V|>��_�]&�>k'��*P��].>L��=N�<I���t��=�"?aM�;��������+>�'��\�I�>�,Ľ�%�<9sk��xཙ?����#�>2�=v佺�m>�mF<⎹=�R>@k%>���=��	=�{�=r&@�e�e�F$I�<>�/�=O > �>٦ȼ��L>���'�<M��@vm�h�X��wY� �������%�C>�	9��>�?�=}M�=z�r�������Km?�����>v<'"<�47=1�:>����ƣ��Q�>�[>�g=��T=�O:�q�<���=>���G=A>޽Oxѽ��J��$>@(5��1=Q:)����ATI>v=>W�(V�=OYc=1����Ѽ!g�=d*�>�-D>&��=�u><ȧ=�쓽B*��<���5#�j򽀇!�Z��:�?�������l�Xh�;_ꮽ�,�f{ҼK�=f����Լ��Q��=4lW���=��6:�ߗ���=l����X���pk�	���߻�<ػ=�,�=�A=�3>$|$��M��V#>4�>q�H���	�����������Xo�Bת��罣-]�/j��-��ڐ�����G���g<[��*'+>��Ҽ��=����B*��멽��Ɗ��>����
o<�*���|�>�wO>�����.�=Θ=�H�>i�R�[U�N�; ��6>�=�d�}�>�cX>�P)�Ph�=[��=���>�w|���%>�h�;�R��==�uL>����w��<�0ϽM���Ľ�Ľ��='/��ަ<sqR>)�]>~f���t�>X�,�I��=�탽]�?�.�>A��F��=��,> �?!����Zʾz�)���'>�OV>��G�Rѯ>߮}>[_��3�=Ν"�_Z>���=��=�����ǽ,V��_Y>��(�K��=+���zZ��z���j�����ؘ�q�%=�Zg>�U]>D�3��a�=)n >v�ּj:��2��=!ő���=`�R��=�x����<����R�=��u=�)�8X�>dAx�[�Խ�b/=�˽dH^�A�ͽ�Y ��c=]1��&��¼�Mͽf�Hx�tp3>�i	=��*>
��w{�=� �<#P9�v��=�>���̽E�)����=z�)�9<����B��\�`Y��5��=�"[�g��=l�������>2d�ގ<���=�@�_�d�|��=WCa� )���O�ԽM�i�:�=D�������g=NG�=R��<�����]<�,= �=��]��-����=U$�>��;����=+������,=B��<��� ��:oj<�/�l���@:��+=����;d=QD���k�B�<}�-��)ܼwJ���=�9���Q<+�<��X��PM��X=ͪ�=�XR>��>ͱ�=�a�<g��=��>�Հa=�򊾗o�?��)>	p�=!�T���޾Ȁ�>��Q���>	���jk��g��>��i��_��Q��6�=�#�>�'>���2��Pe$>墧����~~ؼ;\����T=2zV����|:��V=�i��<�G=p����>pG=w�=���< �=*F>�>�7��ɽ�n��!Ժ�5�<^�t1�<|�D�_�i�S�>����TA���"W>o�>Rw��r潼D9<�V�����;Z�D>�R���*�=%�����=`:�~�j>'m��15ݽ�����=�i�=�3>=(��<I��=��H>U>���z�z��=V����K9>�+"=q2>:���=�r4>���=@�/���L�X`=>콷��=K^'>�?�<�޺=�ԕ=tGO�p�N8h9�
���N�*��=ؚ8��s����q��>�7ؼSA�<ЦK�5�G��7>�$�<�v4����j�4=�ꭾzI'�K�D>�<9=��Ͻ�>b�VG�=��0<��n��s%>D����ف<r�W��)(�|9����>n(��u�=հ=���T�j=�
�=#���F�/��y>���E����k�=�9��H��</˘<�罨�j��D��j�<��s��7��`��Z ��w��B׽~�m=�+ӽ}C߽J�7<X� �s!y>?�P���>�Z�h�?=n%]=z�V=�v�]]���e��O�>e$�=�����m[�ɈU��>�/�>�{�;�Ю;���=���#���7��6���T��3,�	�콦鴽����s���<9�=�y�=�Y����=ƹ�[��=�a�̸>-L���#�X��=�_�=���<�<�6l��n���H�h(�>�֡=v<=>NG��Li�=��μ/��$�>(�=(g�=�8��v��S%�=η#=`�M���=�B�A�.�:���N�v�#H�zn�<�	���]=���=1�>[H�=3�y�jo$=�T���\=��p=��=8i����轥��=�=v��q=�o4�-���=�&X�N���P@�;�����>s�Q�����Y�6>�e���,=u��k�0=��	�_RH=�z��OF��W�b_���0=c�|�A�1K1>2�E=8�3����A��;���3N���>t3��8�=c�f��K�<��>zl��u5T>�����>�@�>a���I���Y4>�_�>�Iy�����y����q�>/�d=�|�>��$>�������=� m�"��>�j����o����O�<?WY���O>��վf<�=n�I��J�3ݼ��i��{>x|�<�@��E�>;W>����<~A>���=��=<᜽珏=xO뽨�>�"�<�J>�w<<G�=X�<�;߽�6t>K7;=&H��<4٥=!tX��o�2�Y��=Ӛ�i���A󆾬���5���˹�R]���g7>�ښ=�&���>��� �=k��=Xw�<*o>b�I�1�i�